#include "PlackettLuce.h"
#include "random.h"
#include "utils.h"
#include <cmath>
#include <cstring>
#include <cstdlib>
#include <iostream>
#include <utility>
using namespace std;


PlackettLuce::PlackettLuce(int n) {
	this->n = n;
	w = new ldouble[n];
	expw = new ldouble[n];
	setUniformParameters();
}


PlackettLuce::~PlackettLuce() {
	if (w) delete[] w;
	if (expw) delete[] expw;
}


void PlackettLuce::setUniformParameters() {
	ldouble u = 1.L/n; //1.L; //M_E;
	ldouble logu = log(u); //0.L; //1.L;
	for (int i=0; i<n; i++) {
		w[i] = logu;
		expw[i] = u;
	}
	sexpw = 1.L; //n; //n*M_E;
}


void PlackettLuce::setDegenerateParameters(int* mode) {
	//upper and lower bounds and range for the weights
	const ldouble ub=+10.L, lb=-10.L;
	//compute step size
	ldouble step = (ub-lb)/(n-1);
	//assign weights such that first has weight ub and last has weight lb
	w[mode[0]] = ub;
	sexpw = expw[mode[0]] = exp(ub);
	for (int i=1; i<n; i++) {
		w[mode[i]] = w[mode[i-1]]-step;
		sexpw += expw[mode[i]] = exp(w[mode[i]]);
	}
	//done
}


void PlackettLuce::sample(int* x) {
	//declare variables and initialize number and sum of remaining indexes to set (i.e. s and nRemInd)
	ldouble s=sexpw, acc, r;
	int remInd[n], nRemInd=n, i,j=-1,k; //j=-1 just to avoid warning from the compiler
	//init remaining indexes to all indexes
	for (i=0; i<n; i++)
		remInd[i] = i;
	//fill x[i], i.e. i-th item of permutation x
	for (i=0; i<n; i++) {
		//random number w in [0,sumOfRemainingWeights)
		r = urand()*s;
		//roulette wheel to select item j (at position k in remInd)
		acc = 0.;
		for (k=0; k<nRemInd; k++) {
			j = remInd[k];
			acc += expw[j];
			if (r<acc) break;
		}
		//this line is to correct possible numerical errors (break never called, so j is ok, but k is too big)
		if (k==nRemInd)
			k--;
		//set x[i] to item j
		x[i] = j;
		//remove item j from remInd
		nRemInd--;
		if (k!=nRemInd)
			remInd[k] = remInd[nRemInd];
		//update sum of remaining weights
		s -= expw[j];
		//end-for
	}
	//done
}


bool PlackettLuce::gradLogProb(ldouble* g, int* x) {
	ldouble sIn = sexpw;
	ldouble sOut = 1.L/sIn;
	g[x[0]] = 1.L - expw[x[0]]*sOut;
	if (isInfNan(sIn) || isInfNan(sOut) || isInfNan(g[x[0]])) return false;
	for (int i=1; i<n; i++) {
		sIn -= expw[x[i-1]];
		sOut += 1.L/sIn;
		g[x[i]] = 1.L - expw[x[i]]*sOut;
		if (isInfNan(sIn) || isInfNan(sOut) || isInfNan(g[x[i]])) return false;
	}
	return true; //if here, everything was ok
}


void PlackettLuce::updateInnerParameters() {
	//BASE VERSION: since w weights were updated by gradientAscent, recompute expw and sexpw
	sexpw = 0.L;
	for (int i=0; i<n; i++)
		sexpw += expw[i] = exp(w[i]);
	/* COMMENTATA PERCHE' NON FUNZIONA DAVVERO MEGLIO DELLA VERSIONE BASE
	//VERSION WITH SOFTMAX TRICK: w weights were updated by gradientAscent: adjust them by subtracting max-weight and recompute expw and sexpw
	ldouble maxw = max(w,n);
	sexpw = 0.L;
	for (int i=0; i<n; i++) {
		w[i] -= maxw;
		sexpw += expw[i] = exp(w[i]); 
	}
	*/
}


void PlackettLuce::mode(int* x) {
	//set ww to "enumerate(w)" (Python style)
	pair<int,ldouble> ww[n];
	for (int i=0; i<n; i++) {
		ww[i].first = i;
		ww[i].second = w[i];
	}
	//sort ww by weights
	qsort(ww,n,sizeof(pair<int,ldouble>),enumeratedLongDoubleComparator);
	//mode is now the inversion of the sorted indexes in ww
	for (int i=0; i<n; i++)
		x[ww[i].first] = i;
	//done
}


ldouble PlackettLuce::entropyParameters() {
	ldouble entr=0.L, p;
	for (int i=0; i<n; i++) {
		p = expw[i]/sexpw;
		entr += -p*log(p);
	}
	return entr;
}


ldouble PlackettLuce::maxProb() {
	ldouble expwMax = expw[0];
	for (int i=1; i<n; i++)
		if (expw[i]>expwMax) expwMax = expw[i];
	return expwMax/sexpw;
}


ldouble PlackettLuce::prob(int* x) {
	//inefficient implementation, but not used!!!
	int i,j;
	ldouble p=1.L,s;
	for (i=0; i<n-1; i++) { //n-1 or n is the same, bcs n-th factor is 1
		s = 0.L;
		for (j=i; j<n; j++)
			s += expw[x[j]];
		p *= expw[x[i]]/s;
	}
	return p;
}


ldouble PlackettLuce::logProb(int* x) {
	//not used!!!
	return log(prob(x));
}


void PlackettLuce::print() {
	cout << "*** PlackettLuce ***\n";
	cout << "n = " << n << "\n";
	printValues(w,n,"w");
	printValues(expw,n,"expw");
	cout << "sexpw = " << sexpw << "\n";
	int x[n];
	mode(x);
	printPerm(x,n,"mode");
	cout << "sizeof(ldouble) = " << sizeof(ldouble) << "\n";
	cout << "********************\n";
}
