#include "utils.h"
#include "random.h"
#include "LopInstance.h"
#include "algorithms.h"
#include <cstdlib>
#include <cstring>
#include <string>
#include <iostream>
using namespace std;


int main(int argc, char** argv) {
	//some variables and their default values
	string lopInstanceName;
	ldouble alpha = 0.01L;
	int lambda = 1000;
	int maxIterations = 10000;
	unsigned int seed = 0;
	int printInterval = 5;
	string utilityFunction = "superlinear";
	//read command line arguments
	if (argc<2) {
		cerr << "USAGE: ./gradientSearch LOP_INSTANCE_FILE [ALPHA=0.01] [LAMBDA=1000] [MAXITERATIONS=10000] [SEED=random] [PRINT_INTERVAL=5] [UTILITY=superlinear]\n";
		cerr << "       Utility functions available: fitness|normalizedFitness|superlinear|linear|equal\n";
		return EXIT_FAILURE;
	}
	lopInstanceName.assign(argv[1],strlen(argv[1]));
	if (argc>2) alpha = (ldouble)atof(argv[2]);
	if (argc>3) lambda = atoi(argv[3]);
	if (argc>4) maxIterations = atoi(argv[4]);
	if (argc>5) sscanf(argv[5],"%u",&seed);
	if (argc>6) printInterval = atoi(argv[6]);
	if (argc>7) utilityFunction.assign(argv[7],strlen(argv[7]));
	//init rng
	if (!seed) seed = randSeed();
	initRand(seed);
	//load LOP instance
	LopInstance lop(lopInstanceName);
	//run gradient ascent
	double fitness = gradientAscent(lop,alpha,lambda,maxIterations,utilityFunction,printInterval,seed); //it prints on the standard output because verbose=true
    FILE *result_file;
	result_file= fopen("data/pleda_gradient/results/gradient_results.csv","a+");
    fprintf(result_file,"\"%s\";%.3f\n",argv[1],fitness);

	//done
	return EXIT_SUCCESS;
}
