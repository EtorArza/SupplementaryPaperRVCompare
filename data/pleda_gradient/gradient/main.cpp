#include "utils.h"
#include "random.h"
#include "LopInstance.h"
#include "algorithms.h"
#include <cstdlib>
#include <cstring>
#include <string>
#include <iostream>
#include <sys/time.h>
using namespace std;


int main(int argc, char** argv) {
	//some variables and their default values
	string lopInstanceName;
	ldouble alpha = 0.1L;
	int lambda = 100;
	int maxEvaluations = 0;
	unsigned int seed = 0;
	string utilityFunction = "superlinear";
	//read command line arguments
	if (argc<2) {
		cerr << "USAGE: ./gradientSearch LOP_INSTANCE_FILE [ALPHA=0.1] [LAMBDA=100] [SEED=random] [UTILITY=superlinear]\n";
		cerr << "       Utility functions available: fitness|normalizedFitness|superlinear|linear|equal\n";
		return EXIT_FAILURE;
	}
	lopInstanceName.assign(argv[1],strlen(argv[1]));
	if (argc>2) alpha = (ldouble)atof(argv[2]);
	if (argc>3) lambda = atoi(argv[3]);
	if (argc>4) sscanf(argv[4],"%u",&seed);
	if (argc>5) utilityFunction.assign(argv[5],strlen(argv[5]));
	//init rng
	if (!seed) seed = randSeed();
	initRand(seed);
	//load LOP instance
	LopInstance lop(lopInstanceName);
	if (!maxEvaluations) maxEvaluations = 1000*lop.n*lop.n;


	//run gradient ascent

	 struct timeval tim;
        gettimeofday(&tim, NULL);
        double start_time=tim.tv_sec+(tim.tv_usec/1000000.0);

	int best_fitness=gradientAscent(lop,alpha,lambda,maxEvaluations,utilityFunction,seed); //it prints on the standard output because verbose=true
	FILE *result_file;
	result_file= fopen("data/pleda_gradient/results/gradient_results.csv","a+");
	cout << "\nbest_fitness -> " << best_fitness << std::endl;
   	fprintf(result_file,"\"%s\";%d\n",argv[1],best_fitness);
	return EXIT_SUCCESS;
}
