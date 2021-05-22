#include "algorithms.h"
#include "LopInstance.h"
#include "PlackettLuce.h"
#include "utils.h"
#include "random.h"
#include <iostream>
#include <cstdlib>
using namespace std;


int main(int argc, char** argv) {
	/*
	initRand(123);
	PlackettLuce pl(50);
	pl.w[0]=0.0253656;pl.w[1]=0.0193228;pl.w[2]=0.0230181;pl.w[3]=0.0119075;pl.w[4]=0.0140032;pl.w[5]=0.0161692;pl.w[6]=0.0215818;pl.w[7]=0.019659;pl.w[8]=0.0205632;pl.w[9]=0.0199766;
	pl.w[10]=0.0256013;pl.w[11]=0.0181763;pl.w[12]=0.0218104;pl.w[13]=0.0222419;pl.w[14]=0.00857338;pl.w[15]=0.0155341;pl.w[16]=0.0245938;pl.w[17]=0.0226432;pl.w[18]=0.0177367;pl.w[19]=0.0148197;
	pl.w[20]=0.0228337;pl.w[21]=0.0243115;pl.w[22]=0.0224461;pl.w[23]=0.0254846;pl.w[24]=0.0240145;pl.w[25]=0.0237013;pl.w[26]=0.0247299;pl.w[27]=0.0252439;pl.w[28]=0.0202774;pl.w[29]=0.0249927;
	pl.w[30]=0.023538;pl.w[31]=0.0220303;pl.w[32]=0.0167408;pl.w[33]=0.0233699;pl.w[34]=0.0104786;pl.w[35]=0.0213437;pl.w[36]=0.0189656;pl.w[37]=0.00571558;pl.w[38]=0.0244544;pl.w[39]=2.7757e-21;
	pl.w[40]=0.0185846;pl.w[41]=0.02386;pl.w[42]=0.0130506;pl.w[43]=0.0208354;pl.w[44]=0.0172604;pl.w[45]=0.0251197;pl.w[46]=0.0241649;pl.w[47]=0.0210952;pl.w[48]=0.0231967;pl.w[49]=0.0248628;
	cout<<pl.s<<"\n";
	int x[50];
	x[0]=47;x[1]=0;x[2]=43;x[3]=25;x[4]=48;x[5]=17;x[6]=44;x[7]=30;x[8]=12;x[9]=7;x[10]=8;x[11]=42;x[12]=27;x[13]=5;x[14]=21;x[15]=9;x[16]=4;x[17]=3;x[18]=40;x[19]=13;x[20]=45;x[21]=36;x[22]=46;x[23]=23;x[24]=16;x[25]=14;x[26]=6;x[27]=24;x[28]=11;x[29]=33;x[30]=49;x[31]=31;x[32]=28;x[33]=19;x[34]=10;x[35]=15;x[36]=38;x[37]=20;x[38]=26;x[39]=32;x[40]=29;x[41]=2;x[42]=22;x[43]=37;x[44]=1;x[45]=41;x[46]=18;x[47]=35;x[48]=34;x[49]=39;
	ldouble g[50];
	pl.gradLogProb(g,x);
	for (int i=0; i<50; i++) cout<<i<<"=>"<<g[i]<<" "; cout<<"\n";
	ldouble delta[50];
	LopInstance lop("../instances/N-be75eec");
	int fx = lop.eval(x);
	cout << "fx="<<fx<<"\n";
	for (int i=0; i<50; i++) delta[i] = (fx/(ldouble)lop.ub) * g[i];
	for (int i=0; i<50; i++) cout<<i<<"=>"<<delta[i]<<" "; cout<<"\n";
	for (int i=0; i<50; i++) pl.w[i]=delta[i];
	pl.correctWeights();
	cout<<"--\n";
	for (int i=0; i<50; i++) cout<<i<<"=>"<<pl.w[i]<<" "; cout<<"\n";
	cout<<"--\n";
	cout<<pl.s<<"\n";
	*/
	/*
	//initRand(randSeed());
	initRand(123);
	LopInstance lop("../instances/N-be75eec");
	gradientAscent(lop,0.01L,1000,10000,true);
	*/
	
	initRand(123);//initRand(randSeed());
	int n = 5;
	PlackettLuce pl(n);
	//int y[n]; for (int i=0; i<n; i++) y[i] = i; //y[0]=n-1; y[n-1]=0;
	//pl.setDegenerateWeights(y);
	pl.w[0]=0.1;pl.w[1]=0.5;pl.w[2]=0.02;pl.w[3]=0.2;pl.w[4]=0.18; //debug
	//pl.w[0]=1;pl.w[1]=5;pl.w[2]=0.2;pl.w[3]=2;pl.w[4]=1.8;pl.correctWeights(); //debug
	pl.updateInnerParameters();//debug
	pl.print();
	int x[n];
	ldouble g[n];
	for (int i=0; i<5; i++) {
		pl.sample(x);
		//if(i==0){x[0]=4;x[1]=1;x[2]=3;x[3]=0;x[4]=2;}//debug
		if (!isValidPerm(x,n)) { cout << "PERMUTATION NOT VALID!!!\n"; return EXIT_FAILURE; }
		printPerm(x,n);
		pl.gradLogProb(g,x);
		printValues(g,n,"g");
	}
	pl.print();
	printPerm(x,n);
	for (int i=0; i<n; i++)
		pl.w[i] += g[i];
	pl.updateInnerParameters();
	pl.print();
	
	/*
	LopInstance lop("../instances/N-be75eec");
	cout << lop.n << " " << lop.lb << " " << lop.ub << " - " << lop.opt << " - " << lop.filename << "\n";
	cout << "---\n";
	for (int i=0; i<lop.n; i++) {
		for (int j=0; j<lop.n; j++)
			cout << lop.lop1[i*lop.n+j] << " ";
		cout << "\n";
	}
	*/
	return EXIT_SUCCESS;
}
