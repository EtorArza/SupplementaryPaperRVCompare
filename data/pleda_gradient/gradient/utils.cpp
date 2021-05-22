#include "utils.h"
#include <cstring>
#include <cmath>
#include <iostream>
using namespace std;


void printPerm(int* x, int n, string name) {
	cout << name << " = [ ";
	for (int i=0; i<n; i++)
		cout << x[i] << (i<n-1?",":"") << " ";
	cout << "]\n";
}

void printValues(ldouble* v, int n, string name) {
	cout << name << " = [ ";
	for (int i=0; i<n; i++)
		cout << v[i] << (i<n-1?",":"") << " ";
	cout << "]\n";
}

bool isValidPerm(int* x, int n) {
	bool present[n];
	memset(present,0,sizeof(bool)*n);
	for (int i=0; i<n; i++) {
		if (present[x[i]]) return false;
		present[x[i]] = true;
	}
	for (int i=0; i<n; i++)
		if (!present[i]) return false;
	return true;
}


void pinv(int* y, int* x, int n) {
	for (int i=0; i<n; i++)
		y[x[i]] = i;
}


int enumeratedLongDoubleComparator(const void* a, const void* b) {
	int r = 0;
	ldouble diff = ((pair<int,ldouble>*)a)->second - ((pair<int,ldouble>*)b)->second;
	if (diff<0.L)
		r = +1; //sorting descending
	else if (diff>0.L)
		r = -1; //sorting descending
	return r;
}


int enumeratedIntComparator(const void* a, const void* b) {
	int r = 0;
	int diff = ((pair<int,int>*)a)->second - ((pair<int,int>*)b)->second;
	if (diff<0.L)
		r = +1; //sorting descending
	else if (diff>0.L)
		r = -1; //sorting descending
	return r;
}


void softmax(ldouble* p, ldouble* w, int n) {
	int i;
	ldouble s = 0.L;
	for (i=0; i<n; i++)
		s += p[i] = exp(w[i]);
	for (i=0; i<n; i++)
		p[i] /= s;
}


void normalize(ldouble* p, ldouble* w, int n) {
	int i;
	ldouble s = 0.L;
	for (i=0; i<n; i++)
		s += p[i] = w[i];
	for (i=0; i<n; i++)
		p[i] /= s;
}


ldouble min(ldouble* v, int n) {
	ldouble r = v[0];
	for (int i=1; i<n; i++)
		if (v[i]<r) r = v[i];
	return r;
}


ldouble max(ldouble* v, int n) {
	ldouble r = v[0];
	for (int i=1; i<n; i++)
		if (v[i]>r) r = v[i];
	return r;
}


ldouble norm(ldouble* v, int n) {
	ldouble r = 0.L;
	for (int i=0; i<n; i++)
		r += v[i]*v[i];
	return sqrt(r);
}


bool isInfNan(ldouble v) {
	return isinf(v) || isnan(v);
}


void copyPerm(int* dst, int* src, int n) {
	memcpy(dst,src,sizeof(int)*n);
}
