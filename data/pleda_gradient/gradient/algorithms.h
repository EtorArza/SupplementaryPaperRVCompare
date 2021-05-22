#ifndef ALGORITHMS_H
#define ALGORITHMS_H

#include "utils.h"
#include "LopInstance.h"

int gradientAscent(LopInstance& lop, ldouble alpha, int lambda, int maxIterations=10000, string utilityFunction="superlinear", int printInterval=0, unsigned int seed=1);

#endif
