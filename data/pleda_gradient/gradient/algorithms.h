#ifndef ALGORITHMS_H
#define ALGORITHMS_H

#include "utils.h"
#include "LopInstance.h"

int gradientAscent(LopInstance& lop, ldouble alpha, int lambda, int maxEvaluations, string utilityFunction="superlinear", unsigned int seed=1);

#endif
