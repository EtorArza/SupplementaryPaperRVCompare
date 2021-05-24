#include "algorithms.h"
#include "PlackettLuce.h"
#include "LopInstance.h"
#include "utility_functions.h"
#include "utils.h"
#include <cmath>
#include <cstdlib>
#include <iostream>
using namespace std;

int gradientAscent(LopInstance& lop, ldouble alpha, int lambda, int maxEvaluations, string utilityFunction, unsigned int seed) {
	int iter,i,k,fmax=-1,nfes=0,n=lop.n,nrestarts=0;
	ldouble delta[n],grad[n];
	bool ok = true;//initialized just to avoid compiler warning
	int opt[n]; //optimum so far
	//setup memory for samples
	int samples1d[n*lambda],fx[lambda];
	int* x[lambda];
	for (i=0; i<lambda; i++)
		x[i] = &samples1d[i*n];
	//setup utility function
	UtilityFunction* uf = UtilityFunction::getUtilityFunction(utilityFunction,x,fx,lambda,&lop);
	//init to uniform distribution
	PlackettLuce pl(n);
	//print header string

	//main loop
	int samples=lambda;
	#define PRINT_EVERY 1000
	cout << " " << endl;
	int print_index = -1;
        while(nfes<maxEvaluations){
			print_index = (print_index + 1) % PRINT_EVERY;

			if(print_index==0) 
			{
				cout<<"\rprogress: "<< (double) nfes / (double) maxEvaluations * 100 << "%" << std::flush;

			}

        	if ((lambda+nfes)>maxEvaluations)
                        samples=(maxEvaluations-nfes);
		//sample lambda permutations and evaluate them
		for (i=0; i<samples; i++) {
			pl.sample(x[i]);
			fx[i] = lop.eval(x[i]);
			nfes++;
			if (fx[i]>fmax) {
				fmax = fx[i];
				copyPerm(opt,x[i],n);
			}
		}
		//calculate delta-vector by means of gradients
		if (nfes<maxEvaluations){
		uf->preUtility();
		for (k=0; k<n; k++)
			delta[k] = 0.L;
		for (i=0; i<lambda; i++) {
			ok = pl.gradLogProb(grad,x[i]);
			if (!ok) break; //exit cycle if there was a numerical problem
			for (k=0; k<n; k++)
				delta[k] += uf->utility(i) * grad[k];
		}
		uf->postUtility();
		
		//update Plackett Luce weights
		if (ok) { //no numerical problem, so update as usual
			for (k=0; k<n; k++)
				pl.w[k] += alpha*delta[k];
			pl.updateInnerParameters();
		} else { //there was a numerical problem, so restart to a degenerate distribution with mode in the optimum so far
			pl.setDegenerateParameters(opt);
			nrestarts++;
		}
	}
		//end-for
	}
	//print something
	//cerr << "fmax      = " << fmax << "\n";
	//cerr << "nrestarts = " << nrestarts << "\n";
	//free memory
	delete uf;
	//return maximum fitness so far
	return fmax;
}
