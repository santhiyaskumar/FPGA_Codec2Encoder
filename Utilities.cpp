
#include "Utilities.h"
#include <iostream>
#include <string>
#include <ctime>
#include "math.h"
#include <bits/stdc++.h>

#include <complex>
#include <iostream>
#include <valarray>

int g =0;

const double PI = 3.141592653589793238460;

typedef std::complex<double> Complex;
typedef std::valarray<Complex> CArray;

#include <iostream>
#include <fstream>


using namespace std;
using std::cos;
using std::sin;


#include <cmath>
#include <vector>
using std::size_t;
using std::vector;

float binaryToFixed(string num){
    float fp, finalfp;
    int rem , dec =0, b=1;
    float points = 0;
    string exp = num.substr(1,15);
    string mant = num.substr(16,16);

    int j = 14;
    for(int i =0; i < 15; i++){
        if((exp.at(i)) == '1'){
            dec += pow(2,j);
        }
        j--;
    }
    for(int i =0; i < 16; i++){
        if((mant.at(i)) == '1') {
            points += pow(0.5, i+1);
        }
    }

    fp = float(dec) + points;
    if(num.at(0) == '1'){
        finalfp = fp - (2*fp);
    }else {
        finalfp = fp;
    }


    return finalfp;
}

void testforloop(){

    float e;
    int diff = 2;
    int k=2;
    int m=2;

    for(int j =0; j <m;j++){
        e = 0.0;
        for (int i = 0; i < k; ++i) {
            e += (diff * 4);
        }
    }
    cout<< endl;
    cout << "testforloop :: e ::" << e << endl;
}



void fixedToBinary(long n){
    // array to store binary number
    int binaryNum[1000];

    // counter for binary array
    int i = 0;
    while (n > 0) {

        // storing remainder in binary array
        binaryNum[i] = n % 2;
        n = n / 2;
        i++;
    }
    //cout<<i<< "  " <<endl;
    //custom output


    for (int j = 0; j < 16 - i; j++) {
        cout << "0";
    }
    // printing binary array in reverse order
    for (int j = i - 1; j >= 0; j--)
        cout << binaryNum[j];

    for (int j = 0; j < 16; j++) {
        cout << "0";
    }

}


void customOutput(){
/*    9'd0:
    begin
    in_cb0 <= cb0;
    in_cb1 <= cb1;
    end*/


    for (int i = 0; i < 256; ++i) {
        cout << "9'd" << i <<":" <<endl;
        cout << "begin" <<endl;
        cout << "   in_cb0 <= cb" << (2*i)+0 << ";" << endl;
        cout << "   in_cb1 <= cb" << (2*i)+1 << ";" << endl;
        cout << "end" <<endl;
    }

}


void generateHeader(string name,string top){
    cout<<"/*" <<endl;
    cout<<"* Module 	 - "<<name<<endl;
    cout<<"* Top module	 - "<<top<<endl;
    cout<<"* Project        - CODEC2_ENCODE_2400"<<endl;
    cout<<"* Developer      - Santhiya S"<<endl;
    cout<<"* Date           - ";
    printTime();

    cout<<"*"<<endl;
    cout<<"* Description    -" <<endl;
    cout<<"* Inputs         -"<<endl;
    cout<<"* Simulation     -"<<endl;

    cout<<"*32 bits fixed point representation"<<endl;
    cout<<"   S - E  - M"<<endl;
    cout<<"   1 - 15 - 16"<<endl;

    cout<<"*/"<<endl;

}


void printTime() {
    time_t now = time(0);

    // convert now to string form
    char* dt = ctime(&now);

    cout << dt ;

    // convert now to tm struct for UTC
    /*  tm *gmtm = gmtime(&now);
      dt = asctime(gmtm);
      cout << "The UTC date and time is:"<< dt << endl;*/
}



string decimalToBinary(double num, int k_prec)
{
    string binary = "";

    // Fetch the integral part of decimal number
    int Integral = num;

    // Fetch the fractional part decimal number
    double fractional = num - Integral;

    // Conversion of integral part to
    // binary equivalent
    while (Integral)
    {
        int rem = Integral % 2;

        // Append 0 in binary
        binary.push_back(rem +'0');

        Integral /= 2;
    }

    // Reverse string to get original binary
    // equivalent
    reverse(binary.begin(),binary.end());

    // Append point before conversion of
    // fractional part
    // binary.push_back('.');

    // Conversion of fractional part to
    // binary equivalent
    while (k_prec--)
    {
        // Find next bit in fraction
        fractional *= 2;
        int fract_bit = fractional;

        if (fract_bit == 1)
        {
            fractional -= fract_bit;
            binary.push_back(1 + '0');
        }
        else
            binary.push_back(0 + '0');
    }

    return binary;
}

void vector_decimaltoBinary(float *codes0,int n){
   // string ret_string = "";
    for(int i =0; i< n;i++){
        double codes_loc;
        if(codes0[i] < 0){
            codes_loc = codes0[i] - (2*codes0[i]);
        }else{
            codes_loc = codes0[i];
        }

        //cout << codes0[i] << endl;

        string codes_bin = decimalToBinary(codes_loc,16);
        int len = codes_bin.length();
        // cb0 = 32'b00000000000000101011010111000010,

        cout  << i << "  : " ;
        //ret_string.append(to_string(i) + " : ");
        if(codes0[i] < 0){
            cout<<"1";
            for(int i =1;i < 32-len;i++) {
                cout << "0" ;
            }
            cout << codes_bin << ";" <<endl;
        }else{
            for(int i =1;i < 33-len;i++) {
                cout << "0" ;
            }
            cout << codes_bin << ";" <<endl;
        }
    }

}


void log2alg(float x){
    //float x = 3;
    float y =0;
    float b=0.5;

    do {
        if (x < 1) {
            x = 2 * x;
            y = y - 1;
        } else if (x >= 2) {
            x = 0.5 * x;
            y = y + 1;
        } else {
            x = x;
            y=y;
        }
    }while(!((x>=1) && (x<2)));

    int n = 10;
    do {
        x = x * x;
        if (x >= 2) {
            x = 0.5 * x;
            y = y + b;
        }
        b = b / 2;
        n--;
    }while(n > 0);

    cout<< "log value ::" << y*0.30102999566 << endl;

}

void call_arcos_cordic(){
    double t = 1;
    int n = 20;
    double angle = arccos_cordic (  t,  n );

    cout << endl;
    cout << "arccos_cordic :: " << angle << endl;
}

double arccos_cordic ( double t, int n )


{
# define ANGLES_LENGTH 17

    double angle;
    double angles[ANGLES_LENGTH] = {
            7.8539816339744830962E-01,
            4.6364760900080611621E-01,
            2.4497866312686415417E-01,
            1.2435499454676143503E-01,
            6.2418809995957348474E-02,
            3.1239833430268276254E-02,
            1.5623728620476830803E-02,
            7.8123410601011112965E-03,
            3.9062301319669718276E-03,
            1.9531225164788186851E-03,
            9.7656218955931943040E-04,
            4.8828121119489827547E-04,
            2.4414062014936176402E-04,
            1.2207031189367020424E-04,
            6.1035156174208775022E-05,
            3.0517578115526096862E-05,
            1.5258789061315762107E-05,


     };
    int i;
    int j;
    double poweroftwo;
    double sigma;
    double sign_z2;
    double theta;
    double x1;
    double x2;
    double y1;
    double y2;

    if ( 1.0 < fabs ( t ) )
    {
        cerr << "\n";
        cerr << "ARCCOS_CORDIC - Fatal error!\n";
        cerr << "  1.0 < |T|.\n";
        exit ( 1 );
    }

    theta = 0.0;
    x1 = 1.0;
    y1 = 0.0;
    poweroftwo = 1.0;

    for ( j = 1; j <= n; j++ )
    {
        if ( y1 < 0.0 )
        {
            sign_z2 = -1.0;
        }
        else
        {
            sign_z2 = +1.0;
        }

        if ( t <= x1 )
        {
            sigma = + sign_z2;
        }
        else
        {
            sigma = - sign_z2;
        }

        if ( j <= 10 )
        {
            angle = angles[j-1];
        }
        else
        {
            angle = angle / 2.0;
        }

        cout << " ::::::" << j << ":::::::" << endl ;
        cout << "sigma , power::  " << sigma << "  " << poweroftwo << endl;
        for ( i = 1; i <= 2; i++ )
        {



            x2 = x1 - (sigma * poweroftwo * y1);
            y2 = (sigma * poweroftwo * x1 )+ y1;

           // cout << "xy2 :: " << x2 << "  " << y2 << endl;
          //  cout << "m2_out :: " << (sigma * poweroftwo * y1) << endl;

            x1 = x2;
            y1 = y2;
        }
       // cout << "xy :: " << x1 << "  " << y1 << endl;
        theta  = theta + 2.0 * sigma * angle;

     //   cout << sigma << ": " << angle << endl;

        t = t + t * poweroftwo * poweroftwo;

        poweroftwo = poweroftwo / 2.0;

        //cout << "theta :: " << theta << endl;
       // cout << sigma << ": " << angle  << "  : " << t << endl;
    }

    return theta;
# undef ANGLES_LENGTH
}


//----y = sqrt(x)---------
float sqrt_fixed(float x){
    unsigned char a,y;
    int i;
    float diff;
    int b = 32;
    a = 2 ^ int(ceil(b / 2)); //b is the wordlength you are using
    y = a;           //a is the first estimation value for sqrt(x)
    for (i=0; i<ceil(b/2); i++)   //each iteration achieves one bit
    {                             //of accuracy
        a    = a*0.5;
        diff = x - y*y;
        if (diff > 0)
        {
            y = y + a;
        }
        else if (diff < 0)
        {
            y = y - a;
        }
    }
    return y;
}


float absolute(float num)
{
    if(num < 0){
        num = -num;
    }
    return num;
}
// Function to calculate square root of the number using Newton-Raphson method
float square_root(float x)
{
    const float difference = 0.001;
    float guess = 1.0;
    int count = 0;
    /*
    while(absolute(guess * guess - x) >= difference){
        guess = (x/guess + guess)/2.0;
        count ++;
    }*/

    for (int i = 0; i < 5; ++i) {
        guess = (x/guess + guess)/2.0;
    }

    cout << count;
    return guess;
}

double fpdiv(double num){
    double mul = 1.0; // power of 2
    double d0 = num;
    int count = 0;
    while (d0 > 1) {
        // divide by 2, will
        // later divide by 2 again
        count ++;
        d0 = d0/2.0;
        mul = mul*2.0;
    }
    while (d0 < 0.5) {
        count ++;
        d0 = d0*2.0;
        mul = mul/2.0;
    }

    double x0 = 1;// 2.82353 - 1.88235 * d0;
    double x1;
    for (int i=0 ;i < 15  ;i++  ) {
        //count ++;
        x1 = x0*(2 - d0*x0);
        x0 = x1;
    }

    cout << "mul " << mul << endl;
    double ans = x1/mul;
    cout << "count :: " << count << endl;
    return ans;
}


string int_to_binary(double num){

    string binary = "";

    // Fetch the integral part of decimal number
    int Integral = num;

    // Fetch the fractional part decimal number
    double fractional = num - Integral;

    // Conversion of integral part to
    // binary equivalent
    while (Integral)
    {
        int rem = Integral % 2;

        // Append 0 in binary
        binary.push_back(rem +'0');

        Integral /= 2;
    }

    // Reverse string to get original binary
    // equivalent
    reverse(binary.begin(),binary.end());


    return binary;

}

void vector_int_to_binary(int *vector,int n){
    for (int i = 0; i < n; ++i) {
        string bin_num =  int_to_binary(vector[i]);
        int len = bin_num.length();
        cout << i << "   :   ";
        for(int j = 1;j < 80-len;j++) {
            cout << "0" ;
        }
        cout << bin_num << ";" << endl;
    }
}

void call_cossin_cordic(){
    double t = 1;
    int n = 16;
    //double angle = arccos_cordic (  t,  n );
    double c, s;
    cossin_cordic ( 6.2953, n, c ,  s );

    cout << endl;
    cout << "cos_sin :: " << c << "::    " << s << endl;
}

void cossin_cordic ( double beta, int n, double &c, double &s )

{
# define ANGLES_LENGTH 20
# define KPROD_LENGTH 20

    double angle;
   /* double angles[ANGLES_LENGTH] = {
            7.8539816339744830962E-01,
            4.6364760900080611621E-01,
            2.4497866312686415417E-01,
            1.2435499454676143503E-01,
            6.2418809995957348474E-02,
            3.1239833430268276254E-02,
            1.5623728620476830803E-02,
            7.8123410601011112965E-03,
            3.9062301319669718276E-03,
            1.9531225164788186851E-03,
            9.7656218955931943040E-04,
            4.8828121119489827547E-04,
            2.4414062014936176402E-04,
            1.2207031189367020424E-04,
            6.1035156174208775022E-05,
            3.0517578115526096862E-05,
            1.5258789061315762107E-05,
            7.6293945311019702634E-06,
            3.8146972656064962829E-06,
            1.9073486328101870354E-06,
            9.5367431640596087942E-07,
            4.7683715820308885993E-07,
            2.3841857910155798249E-07,
            1.1920928955078068531E-07,
            5.9604644775390554414E-08,
            2.9802322387695303677E-08,
            1.4901161193847655147E-08,
            7.4505805969238279871E-09,
            3.7252902984619140453E-09,
            1.8626451492309570291E-09,
            9.3132257461547851536E-10,
            4.6566128730773925778E-10,
            2.3283064365386962890E-10,
            1.1641532182693481445E-10,
            5.8207660913467407226E-11,
            2.9103830456733703613E-11,
            1.4551915228366851807E-11,
            7.2759576141834259033E-12,
            3.6379788070917129517E-12,
            1.8189894035458564758E-12,
            9.0949470177292823792E-13,
            4.5474735088646411896E-13,
            2.2737367544323205948E-13,
            1.1368683772161602974E-13,
            5.6843418860808014870E-14,
            2.8421709430404007435E-14,
            1.4210854715202003717E-14,
            7.1054273576010018587E-15,
            3.5527136788005009294E-15,
            1.7763568394002504647E-15,
            8.8817841970012523234E-16,
            4.4408920985006261617E-16,
            2.2204460492503130808E-16,
            1.1102230246251565404E-16,
            5.5511151231257827021E-17,
            2.7755575615628913511E-17,
            1.3877787807814456755E-17,
            6.9388939039072283776E-18,
            3.4694469519536141888E-18,
            1.7347234759768070944E-18 };*/
    double angles[ANGLES_LENGTH] = {
            7.8539816339744830962E-01,
            4.6364760900080611621E-01,
            2.4497866312686415417E-01,
            1.2435499454676143503E-01,
            6.2418809995957348474E-02,
            3.1239833430268276254E-02,
            1.5623728620476830803E-02,
            7.8123410601011112965E-03,
            3.9062301319669718276E-03,
            1.9531225164788186851E-03,
            9.7656218955931943040E-04,
            4.8828121119489827547E-04,
            2.4414062014936176402E-04,
            1.2207031189367020424E-04,
            6.1035156174208775022E-05,
            3.0517578115526096862E-05,
            1.5258789061315762107E-05,
            7.6293945311019702634E-06,
            3.8146972656064962829E-06,
            1.9073486328101870354E-06};

    double c2;
    double factor;
    int j;
    double kprod[KPROD_LENGTH] = {
            0.70710678118654752440,
            0.63245553203367586640,
            0.61357199107789634961,
            0.60883391251775242102,
            0.60764825625616820093,
            0.60735177014129595905,
            0.60727764409352599905,
            0.60725911229889273006,
            0.60725447933256232972,
            0.60725332108987516334,
            0.60725303152913433540,
            0.60725295913894481363,
            0.60725294104139716351,
            0.60725293651701023413,
            0.60725293538591350073,
            0.60725293510313931731,
            0.60725293503244577146,
            0.60725293501477238499,
            0.60725293501035403837,
            0.60725293500924945172};
           /* 0.60725293500897330506,
            0.60725293500890426839,
            0.60725293500888700922,
            0.60725293500888269443,
            0.60725293500888161574,
            0.60725293500888134606,
            0.60725293500888127864,
            0.60725293500888126179,
            0.60725293500888125757,
            0.60725293500888125652,
            0.60725293500888125626,
            0.60725293500888125619,
            0.60725293500888125617 };*/

    double pi = 3.141592653589793;
    double poweroftwo;
    double s2;
    double sigma;
    double sign_factor;
    double theta;
//
//  Shift angle to interval [-pi,pi].
//
    theta = angle_shift ( beta, -pi );

    cout << "theta  :: "<< theta << endl;
//
//  Shift angle to interval [-pi/2,pi/2] and account for signs.
//
    if ( theta < - 0.5 * pi )
    {
        theta = theta + pi;
        sign_factor = -1.0;
    }
    else if ( 0.5 * pi < theta )
    {
        theta = theta - pi;
        sign_factor = -1.0;
    }
    else
    {
        sign_factor = +1.0;
    }

    cout << "theta  :: "<< theta << "  ::: sign ::  " <<sign_factor <<  endl;
//
//  Initialize loop variables:
//
    c = 1.0;
    s = 0.0;

    poweroftwo = 1.0;
    angle = angles[0];
//
//  Iterations
//
    for ( j = 1; j <= n; j++ )
    {
        if ( theta < 0.0 ){
            sigma = -1.0;
        }else {
            sigma = 1.0;
        }
        factor = sigma * poweroftwo;
        c2 =          c - factor * s;
        s2 = factor * c +          s;
        c = c2;
        s = s2;
//
//  Update the remaining angle.
//
        theta = theta - sigma * angle;

        poweroftwo = poweroftwo / 2.0;

        //cout << endl;
        //cout << "theta in :: " << theta << endl;
       // cout  << "poweroftwo :: " << poweroftwo << endl;

//
//  Update the angle from table, or eventually by just dividing by two.
//
        if ( ANGLES_LENGTH < j + 1 ) {
            angle = angle / 2.0;
        }else{
            angle = angles[j];
        }

        cout << "c :: " << c << " :: s ::" << s << endl;
    }
//
//  Adjust length of output vector to be [cos(beta), sin(beta)]
//
//  KPROD is essentially constant after a certain point, so if N is
//  large, just take the last available value.
//
    if ( 0 < n )
    {
        c = c * kprod [ i4_min ( n, KPROD_LENGTH ) - 1 ];
        s = s * kprod [ i4_min ( n, KPROD_LENGTH ) - 1 ];
    }
//
//  Adjust for possible sign change because angle was originally
//  not in quadrant 1 or 4.
//
    c = sign_factor * c;
    s = sign_factor * s;

    return;
# undef ANGLES_LENGTH
# undef KPROD_LENGTH
}

double angle_shift ( double alpha, double beta )


{
    double gamma;
    double pi = 3.141592653589793;

    if ( alpha < beta )
    {
       // cout << "if" << endl;
        gamma = beta - fmod ( beta - alpha, 2.0 * pi ) + 2.0 * pi;
    }
    else
    {
        //cout << "else" << endl;
        gamma = beta + fmod ( alpha - beta, 2.0 * pi );
       // cout << "fmod ::" << fmod ( alpha - beta, 2.0 * pi )  << " :: " <<  alpha - beta << endl;
    }

    return gamma;
}

int i4_min ( int i1, int i2 )

{
    int value;

    if ( i1 < i2 )
    {
        value = i1;
    }
    else
    {
        value = i2;
    }
    return value;
}

void call_computeDft(){


    computeDft();


}

/*void computeDft(const vector<double> &inreal, const vector<double> &inimag,
                vector<double> &outreal, vector<double> &outimag) */
void computeDft() {
    float inreal[512];
    inreal[0] = -0.000000;
    inreal[1] = 99.580856;
    inreal[2] = 1538.427612;
    inreal[3] = -23294.869141;
    inreal[4] = 122918.164062;
    inreal[5] = 419718.093750;
    inreal[6] = 382411.312500;
    inreal[7] = 683033.500000;
    inreal[8] = 96494.125000;
    inreal[9] = -747831.500000;
    inreal[10] = -408518.437500;
    inreal[11] = -506583.343750;
    inreal[12] = 368036.281250;
    inreal[13] = -3216464.250000;
    inreal[14] = 102990.093750;
    inreal[15] = 59090980.000000;
    inreal[16] = 61493836.000000;
    inreal[17] = -4928778.000000;
    inreal[18] = 11451445.000000;
    inreal[19] = -2573945.750000;
    inreal[20] = -37030924.000000;
    inreal[21] = -19129906.000000;
    inreal[22] = -21872802.000000;
    inreal[23] = -24779040.000000;
    inreal[24] = -17185018.000000;
    inreal[25] = -19036456.000000;
    inreal[26] = -13511224.000000;
    inreal[27] = -9654469.000000;
    inreal[28] = -12347666.000000;
    inreal[29] = -7760242.000000;
    inreal[30] = -12316448.000000;
    inreal[31] = -9089885.000000;
    inreal[32] = 98950848.000000;
    inreal[33] = 113253344.000000;
    inreal[34] = -607320.312500;
    inreal[35] = 21840510.000000;
    inreal[36] = 16362524.000000;
    inreal[37] = -43856164.000000;
    inreal[38] = -20187492.000000;
    inreal[39] = -15505843.000000;
    inreal[40] = -27911472.000000;
    inreal[41] = -14518409.000000;
    inreal[42] = -14611131.000000;
    inreal[43] = -14763526.000000;
    inreal[44] = -7217460.000000;
    inreal[45] = -6688596.000000;
    inreal[46] = -7407394.000000;
    inreal[47] = -5731451.000000;
    inreal[48] = -9319183.000000;
    inreal[49] = 22762622.000000;
    inreal[50] = 45534340.000000;
    inreal[51] = 6901984.000000;
    inreal[52] = 2137276.000000;
    inreal[53] = 10155545.000000;
    inreal[54] = -6077161.000000;
    inreal[55] = -4399178.500000;
    inreal[56] = -96700.101562;
    inreal[57] = -3012016.500000;
    inreal[58] = -1539678.125000;
    inreal[59] = -622260.562500;
    inreal[60] = -579556.125000;
    inreal[61] = -156354.218750;
    inreal[62] = -25530.783203;
    inreal[63] = -0.000000;
    inreal[64] = 0.000000;
    inreal[65] = 0.000000;
    inreal[66] = 0.000000;
    inreal[67] = 0.000000;
    inreal[68] = 0.000000;
    inreal[69] = 0.000000;
    inreal[70] = 0.000000;
    inreal[71] = 0.000000;
    inreal[72] = 0.000000;
    inreal[73] = 0.000000;
    inreal[74] = 0.000000;
    inreal[75] = 0.000000;
    inreal[76] = 0.000000;
    inreal[77] = 0.000000;
    inreal[78] = 0.000000;
    inreal[79] = 0.000000;
    inreal[80] = 0.000000;
    inreal[81] = 0.000000;
    inreal[82] = 0.000000;
    inreal[83] = 0.000000;
    inreal[84] = 0.000000;
    inreal[85] = 0.000000;
    inreal[86] = 0.000000;
    inreal[87] = 0.000000;
    inreal[88] = 0.000000;
    inreal[89] = 0.000000;
    inreal[90] = 0.000000;
    inreal[91] = 0.000000;
    inreal[92] = 0.000000;
    inreal[93] = 0.000000;
    inreal[94] = 0.000000;
    inreal[95] = 0.000000;
    inreal[96] = 0.000000;
    inreal[97] = 0.000000;
    inreal[98] = 0.000000;
    inreal[99] = 0.000000;
    inreal[100] = 0.000000;
    inreal[101] = 0.000000;
    inreal[102] = 0.000000;
    inreal[103] = 0.000000;
    inreal[104] = 0.000000;
    inreal[105] = 0.000000;
    inreal[106] = 0.000000;
    inreal[107] = 0.000000;
    inreal[108] = 0.000000;
    inreal[109] = 0.000000;
    inreal[110] = 0.000000;
    inreal[111] = 0.000000;
    inreal[112] = 0.000000;
    inreal[113] = 0.000000;
    inreal[114] = 0.000000;
    inreal[115] = 0.000000;
    inreal[116] = 0.000000;
    inreal[117] = 0.000000;
    inreal[118] = 0.000000;
    inreal[119] = 0.000000;
    inreal[120] = 0.000000;
    inreal[121] = 0.000000;
    inreal[122] = 0.000000;
    inreal[123] = 0.000000;
    inreal[124] = 0.000000;
    inreal[125] = 0.000000;
    inreal[126] = 0.000000;
    inreal[127] = 0.000000;
    inreal[128] = 0.000000;
    inreal[129] = 0.000000;
    inreal[130] = 0.000000;
    inreal[131] = 0.000000;
    inreal[132] = 0.000000;
    inreal[133] = 0.000000;
    inreal[134] = 0.000000;
    inreal[135] = 0.000000;
    inreal[136] = 0.000000;
    inreal[137] = 0.000000;
    inreal[138] = 0.000000;
    inreal[139] = 0.000000;
    inreal[140] = 0.000000;
    inreal[141] = 0.000000;
    inreal[142] = 0.000000;
    inreal[143] = 0.000000;
    inreal[144] = 0.000000;
    inreal[145] = 0.000000;
    inreal[146] = 0.000000;
    inreal[147] = 0.000000;
    inreal[148] = 0.000000;
    inreal[149] = 0.000000;
    inreal[150] = 0.000000;
    inreal[151] = 0.000000;
    inreal[152] = 0.000000;
    inreal[153] = 0.000000;
    inreal[154] = 0.000000;
    inreal[155] = 0.000000;
    inreal[156] = 0.000000;
    inreal[157] = 0.000000;
    inreal[158] = 0.000000;
    inreal[159] = 0.000000;
    inreal[160] = 0.000000;
    inreal[161] = 0.000000;
    inreal[162] = 0.000000;
    inreal[163] = 0.000000;
    inreal[164] = 0.000000;
    inreal[165] = 0.000000;
    inreal[166] = 0.000000;
    inreal[167] = 0.000000;
    inreal[168] = 0.000000;
    inreal[169] = 0.000000;
    inreal[170] = 0.000000;
    inreal[171] = 0.000000;
    inreal[172] = 0.000000;
    inreal[173] = 0.000000;
    inreal[174] = 0.000000;
    inreal[175] = 0.000000;
    inreal[176] = 0.000000;
    inreal[177] = 0.000000;
    inreal[178] = 0.000000;
    inreal[179] = 0.000000;
    inreal[180] = 0.000000;
    inreal[181] = 0.000000;
    inreal[182] = 0.000000;
    inreal[183] = 0.000000;
    inreal[184] = 0.000000;
    inreal[185] = 0.000000;
    inreal[186] = 0.000000;
    inreal[187] = 0.000000;
    inreal[188] = 0.000000;
    inreal[189] = 0.000000;
    inreal[190] = 0.000000;
    inreal[191] = 0.000000;
    inreal[192] = 0.000000;
    inreal[193] = 0.000000;
    inreal[194] = 0.000000;
    inreal[195] = 0.000000;
    inreal[196] = 0.000000;
    inreal[197] = 0.000000;
    inreal[198] = 0.000000;
    inreal[199] = 0.000000;
    inreal[200] = 0.000000;
    inreal[201] = 0.000000;
    inreal[202] = 0.000000;
    inreal[203] = 0.000000;
    inreal[204] = 0.000000;
    inreal[205] = 0.000000;
    inreal[206] = 0.000000;
    inreal[207] = 0.000000;
    inreal[208] = 0.000000;
    inreal[209] = 0.000000;
    inreal[210] = 0.000000;
    inreal[211] = 0.000000;
    inreal[212] = 0.000000;
    inreal[213] = 0.000000;
    inreal[214] = 0.000000;
    inreal[215] = 0.000000;
    inreal[216] = 0.000000;
    inreal[217] = 0.000000;
    inreal[218] = 0.000000;
    inreal[219] = 0.000000;
    inreal[220] = 0.000000;
    inreal[221] = 0.000000;
    inreal[222] = 0.000000;
    inreal[223] = 0.000000;
    inreal[224] = 0.000000;
    inreal[225] = 0.000000;
    inreal[226] = 0.000000;
    inreal[227] = 0.000000;
    inreal[228] = 0.000000;
    inreal[229] = 0.000000;
    inreal[230] = 0.000000;
    inreal[231] = 0.000000;
    inreal[232] = 0.000000;
    inreal[233] = 0.000000;
    inreal[234] = 0.000000;
    inreal[235] = 0.000000;
    inreal[236] = 0.000000;
    inreal[237] = 0.000000;
    inreal[238] = 0.000000;
    inreal[239] = 0.000000;
    inreal[240] = 0.000000;
    inreal[241] = 0.000000;
    inreal[242] = 0.000000;
    inreal[243] = 0.000000;
    inreal[244] = 0.000000;
    inreal[245] = 0.000000;
    inreal[246] = 0.000000;
    inreal[247] = 0.000000;
    inreal[248] = 0.000000;
    inreal[249] = 0.000000;
    inreal[250] = 0.000000;
    inreal[251] = 0.000000;
    inreal[252] = 0.000000;
    inreal[253] = 0.000000;
    inreal[254] = 0.000000;
    inreal[255] = 0.000000;
    inreal[256] = 0.000000;
    inreal[257] = 0.000000;
    inreal[258] = 0.000000;
    inreal[259] = 0.000000;
    inreal[260] = 0.000000;
    inreal[261] = 0.000000;
    inreal[262] = 0.000000;
    inreal[263] = 0.000000;
    inreal[264] = 0.000000;
    inreal[265] = 0.000000;
    inreal[266] = 0.000000;
    inreal[267] = 0.000000;
    inreal[268] = 0.000000;
    inreal[269] = 0.000000;
    inreal[270] = 0.000000;
    inreal[271] = 0.000000;
    inreal[272] = 0.000000;
    inreal[273] = 0.000000;
    inreal[274] = 0.000000;
    inreal[275] = 0.000000;
    inreal[276] = 0.000000;
    inreal[277] = 0.000000;
    inreal[278] = 0.000000;
    inreal[279] = 0.000000;
    inreal[280] = 0.000000;
    inreal[281] = 0.000000;
    inreal[282] = 0.000000;
    inreal[283] = 0.000000;
    inreal[284] = 0.000000;
    inreal[285] = 0.000000;
    inreal[286] = 0.000000;
    inreal[287] = 0.000000;
    inreal[288] = 0.000000;
    inreal[289] = 0.000000;
    inreal[290] = 0.000000;
    inreal[291] = 0.000000;
    inreal[292] = 0.000000;
    inreal[293] = 0.000000;
    inreal[294] = 0.000000;
    inreal[295] = 0.000000;
    inreal[296] = 0.000000;
    inreal[297] = 0.000000;
    inreal[298] = 0.000000;
    inreal[299] = 0.000000;
    inreal[300] = 0.000000;
    inreal[301] = 0.000000;
    inreal[302] = 0.000000;
    inreal[303] = 0.000000;
    inreal[304] = 0.000000;
    inreal[305] = 0.000000;
    inreal[306] = 0.000000;
    inreal[307] = 0.000000;
    inreal[308] = 0.000000;
    inreal[309] = 0.000000;
    inreal[310] = 0.000000;
    inreal[311] = 0.000000;
    inreal[312] = 0.000000;
    inreal[313] = 0.000000;
    inreal[314] = 0.000000;
    inreal[315] = 0.000000;
    inreal[316] = 0.000000;
    inreal[317] = 0.000000;
    inreal[318] = 0.000000;
    inreal[319] = 0.000000;
    inreal[320] = 0.000000;
    inreal[321] = 0.000000;
    inreal[322] = 0.000000;
    inreal[323] = 0.000000;
    inreal[324] = 0.000000;
    inreal[325] = 0.000000;
    inreal[326] = 0.000000;
    inreal[327] = 0.000000;
    inreal[328] = 0.000000;
    inreal[329] = 0.000000;
    inreal[330] = 0.000000;
    inreal[331] = 0.000000;
    inreal[332] = 0.000000;
    inreal[333] = 0.000000;
    inreal[334] = 0.000000;
    inreal[335] = 0.000000;
    inreal[336] = 0.000000;
    inreal[337] = 0.000000;
    inreal[338] = 0.000000;
    inreal[339] = 0.000000;
    inreal[340] = 0.000000;
    inreal[341] = 0.000000;
    inreal[342] = 0.000000;
    inreal[343] = 0.000000;
    inreal[344] = 0.000000;
    inreal[345] = 0.000000;
    inreal[346] = 0.000000;
    inreal[347] = 0.000000;
    inreal[348] = 0.000000;
    inreal[349] = 0.000000;
    inreal[350] = 0.000000;
    inreal[351] = 0.000000;
    inreal[352] = 0.000000;
    inreal[353] = 0.000000;
    inreal[354] = 0.000000;
    inreal[355] = 0.000000;
    inreal[356] = 0.000000;
    inreal[357] = 0.000000;
    inreal[358] = 0.000000;
    inreal[359] = 0.000000;
    inreal[360] = 0.000000;
    inreal[361] = 0.000000;
    inreal[362] = 0.000000;
    inreal[363] = 0.000000;
    inreal[364] = 0.000000;
    inreal[365] = 0.000000;
    inreal[366] = 0.000000;
    inreal[367] = 0.000000;
    inreal[368] = 0.000000;
    inreal[369] = 0.000000;
    inreal[370] = 0.000000;
    inreal[371] = 0.000000;
    inreal[372] = 0.000000;
    inreal[373] = 0.000000;
    inreal[374] = 0.000000;
    inreal[375] = 0.000000;
    inreal[376] = 0.000000;
    inreal[377] = 0.000000;
    inreal[378] = 0.000000;
    inreal[379] = 0.000000;
    inreal[380] = 0.000000;
    inreal[381] = 0.000000;
    inreal[382] = 0.000000;
    inreal[383] = 0.000000;
    inreal[384] = 0.000000;
    inreal[385] = 0.000000;
    inreal[386] = 0.000000;
    inreal[387] = 0.000000;
    inreal[388] = 0.000000;
    inreal[389] = 0.000000;
    inreal[390] = 0.000000;
    inreal[391] = 0.000000;
    inreal[392] = 0.000000;
    inreal[393] = 0.000000;
    inreal[394] = 0.000000;
    inreal[395] = 0.000000;
    inreal[396] = 0.000000;
    inreal[397] = 0.000000;
    inreal[398] = 0.000000;
    inreal[399] = 0.000000;
    inreal[400] = 0.000000;
    inreal[401] = 0.000000;
    inreal[402] = 0.000000;
    inreal[403] = 0.000000;
    inreal[404] = 0.000000;
    inreal[405] = 0.000000;
    inreal[406] = 0.000000;
    inreal[407] = 0.000000;
    inreal[408] = 0.000000;
    inreal[409] = 0.000000;
    inreal[410] = 0.000000;
    inreal[411] = 0.000000;
    inreal[412] = 0.000000;
    inreal[413] = 0.000000;
    inreal[414] = 0.000000;
    inreal[415] = 0.000000;
    inreal[416] = 0.000000;
    inreal[417] = 0.000000;
    inreal[418] = 0.000000;
    inreal[419] = 0.000000;
    inreal[420] = 0.000000;
    inreal[421] = 0.000000;
    inreal[422] = 0.000000;
    inreal[423] = 0.000000;
    inreal[424] = 0.000000;
    inreal[425] = 0.000000;
    inreal[426] = 0.000000;
    inreal[427] = 0.000000;
    inreal[428] = 0.000000;
    inreal[429] = 0.000000;
    inreal[430] = 0.000000;
    inreal[431] = 0.000000;
    inreal[432] = 0.000000;
    inreal[433] = 0.000000;
    inreal[434] = 0.000000;
    inreal[435] = 0.000000;
    inreal[436] = 0.000000;
    inreal[437] = 0.000000;
    inreal[438] = 0.000000;
    inreal[439] = 0.000000;
    inreal[440] = 0.000000;
    inreal[441] = 0.000000;
    inreal[442] = 0.000000;
    inreal[443] = 0.000000;
    inreal[444] = 0.000000;
    inreal[445] = 0.000000;
    inreal[446] = 0.000000;
    inreal[447] = 0.000000;
    inreal[448] = 0.000000;
    inreal[449] = 0.000000;
    inreal[450] = 0.000000;
    inreal[451] = 0.000000;
    inreal[452] = 0.000000;
    inreal[453] = 0.000000;
    inreal[454] = 0.000000;
    inreal[455] = 0.000000;
    inreal[456] = 0.000000;
    inreal[457] = 0.000000;
    inreal[458] = 0.000000;
    inreal[459] = 0.000000;
    inreal[460] = 0.000000;
    inreal[461] = 0.000000;
    inreal[462] = 0.000000;
    inreal[463] = 0.000000;
    inreal[464] = 0.000000;
    inreal[465] = 0.000000;
    inreal[466] = 0.000000;
    inreal[467] = 0.000000;
    inreal[468] = 0.000000;
    inreal[469] = 0.000000;
    inreal[470] = 0.000000;
    inreal[471] = 0.000000;
    inreal[472] = 0.000000;
    inreal[473] = 0.000000;
    inreal[474] = 0.000000;
    inreal[475] = 0.000000;
    inreal[476] = 0.000000;
    inreal[477] = 0.000000;
    inreal[478] = 0.000000;
    inreal[479] = 0.000000;
    inreal[480] = 0.000000;
    inreal[481] = 0.000000;
    inreal[482] = 0.000000;
    inreal[483] = 0.000000;
    inreal[484] = 0.000000;
    inreal[485] = 0.000000;
    inreal[486] = 0.000000;
    inreal[487] = 0.000000;
    inreal[488] = 0.000000;
    inreal[489] = 0.000000;
    inreal[490] = 0.000000;
    inreal[491] = 0.000000;
    inreal[492] = 0.000000;
    inreal[493] = 0.000000;
    inreal[494] = 0.000000;
    inreal[495] = 0.000000;
    inreal[496] = 0.000000;
    inreal[497] = 0.000000;
    inreal[498] = 0.000000;
    inreal[499] = 0.000000;
    inreal[500] = 0.000000;
    inreal[501] = 0.000000;
    inreal[502] = 0.000000;
    inreal[503] = 0.000000;
    inreal[504] = 0.000000;
    inreal[505] = 0.000000;
    inreal[506] = 0.000000;
    inreal[507] = 0.000000;
    inreal[508] = 0.000000;
    inreal[509] = 0.000000;
    inreal[510] = 0.000000;
    inreal[511] = 0.000000;
    float inimag[512];
    float outreal[512];
    float outimag[512];

    for (int j = 0; j < 512; ++j) {
        inimag[j] = 0;
        outreal[j] =0;
        outimag[j] = 0;
    }

    int n = 512;
    float p;
    float max = 0;
    for (int k = 0; k < 512; k++) {  // For each output element
        float sumreal = 0;
        float sumimag = 0;
        float angle = 0;

     //   cout << "::::::::: " << k <<" ::::::::::::" << endl;
        for (int t = 0; t < 512; t++) {  // For each input element
            angle = 2 * M_PI * t * k / n;
            p =2 * M_PI * t * k;


            sumreal +=  inreal[t] * cos(angle) + inimag[t] * sin(angle);
            sumimag += -inreal[t] * sin(angle) + inimag[t] * cos(angle);
           // cout << "t :: " << t << " :: " << angle << endl;
            if(angle > max){
                max = angle;
            }
           // cout << k << " :: t = " << t << " :: " << cos(angle) << " ::: " << sin(angle) << "   angle :: " << angle <<  endl;
            if(t>=0 && t <= 511 && k == 509)
               cout << k << " :: t = " << t << " :: " << std::setprecision(4)<< cos(angle) << " ::: " << sin(angle) << "   angle :: "  << angle << "   mod    "<< fmod(angle,2*M_PI) <<  endl;


        }
        outreal[k] = sumreal;
        outimag[k] = sumimag;
        //cout.precision(5);



       // cout << "angle :: " << angle << endl;
        //cout << "cos::" << cos(angle) << endl;
        //cout << "sin::" << sin(angle) << endl;
      //  cout << fixed <<"outreal :: " << sumreal << " :: outimag :: " << sumimag << endl;
    }
    for (int i = 510; i < 512 ; ++i) {
        cout << i << ":: outreal :: " << outreal[i] << " :: outimag :: " << outimag[i] << endl;
    }
    //DFT end

   /* if(t ==10&& k ==10)
        cout << k << " :: t = " << t << " :: " << cos(angle) << " ::: " << sin(angle) << "   angle :: " << angle <<  endl;*/

   cout << "max angle :: " << max   << " sin :: " << sin(max)<< endl;
}


string vector_decimaltoBinary_string(float *codes0,int n){
    string ret_string = "";
    for(int i =0; i< n;i++){
        double codes_loc;
        if(codes0[i] < 0){
            codes_loc = codes0[i] - (2*codes0[i]);
        }else{
            codes_loc = codes0[i];
        }

        //cout << codes0[i] << endl;

        string codes_bin = decimalToBinary(codes_loc,16);
        int len = codes_bin.length();
        // cb0 = 32'b00000000000000101011010111000010,

        // cout  << i << "  : " ;
        ret_string.append(to_string(i) + " : ");
        if(codes0[i] < 0){
            //cout<<"1";
            ret_string.append("1");
            for(int i =1;i < 32-len;i++) {
                //cout << "0" ;
                ret_string.append("0");
            }
            //cout << codes_bin << ";" <<endl;
            ret_string.append(codes_bin+";");
            ret_string.append("\n");
        }else{
            for(int i =1;i < 33-len;i++) {
                //cout << "0" ;
                ret_string.append("0");
            }
            //cout << codes_bin << ";" <<endl;
            ret_string.append(codes_bin+";");
            ret_string.append("\n");
        }
    }
    return ret_string;



}



void vector_decimaltoBinary_80(float *codes0,int n){
    // string ret_string = "";
    for(int i =0; i< n;i++){
        double codes_loc;
        if(codes0[i] < 0){
            codes_loc = codes0[i] - (2*codes0[i]);
        }else{
            codes_loc = codes0[i];
        }

        //cout << codes0[i] << endl;

        string codes_bin = decimalToBinary(codes_loc,16);
        int len = codes_bin.length();
        // cb0 = 32'b00000000000000101011010111000010,

        //cout  << "nlp_fir" << i << "  = 80'b" ;
        cout << i << "  :  ";
        //ret_string.append(to_string(i) + " : ");
        if(codes0[i] < 0){
            cout<<"1";
            for(int i =1;i < 80-len;i++) {
                cout << "0" ;
            }
            cout << codes_bin << ";" <<endl;
        }else{
            for(int i =1;i < 81-len;i++) {
                cout << "0" ;
            }
            cout << codes_bin << ";" <<endl;
        }
    }

}


string decimalToHex(int n){
    string hexaDeciNum;

    // counter for hexadecimal number array
    int i = 0;
    while(n!=0)
    {
        // temporary variable to store remainder
        int temp  = 0;

        // storing remainder in temp variable.
        temp = n % 16;

        // check if temp < 10
        if(temp < 10)
        {
            //hexaDeciNum[i] = temp + 48;
            hexaDeciNum.push_back(temp + 48);
            i++;
        }
        else
        {
            //hexaDeciNum[i] = temp + 55;
            hexaDeciNum.push_back(temp + 55);
            i++;
        }

        n = n/16;
    }

    // printing hexadecimal number array in reverse order
    reverse(hexaDeciNum.begin(),hexaDeciNum.end());
    return  hexaDeciNum;
}


bool isPrime(unsigned long long int  n){
    unsigned long long int sqroot_n = sqrt(n);

    for(unsigned long long int  i =2; i <= sqroot_n;i++) {
        if (n % i == 0) {
            return false;
        }
    }
    return true;
}

void listPrimeNumbers(unsigned long long int  n1, unsigned long long int  n2){
    unsigned long long int  count = 0;
    for(unsigned long long int  i=n1; i <= n2;i++){
        if(isPrime(i)){
            count = count + 1;
            cout<< count << " = " << i << endl;
            break;
        }
    }
}


void createMif(){

    float speech[160] =  {
            -18,-24,-25,-26,-26,-25,-22,-24,-26,-21,-18,-18,-14,-9,-7,-5,0,-2,-8,-2,
            -8,-11,-12,-12,-15,-12,-14,-15,-19,-15,-12,-8,-4,-11,-11,-12,-15,-11,-18,-15,
            -16,-16,-19,-22,-19,-26,-28,-22,-19,-24,-25,-24,-24,-24,-18,-19,-24,-25,-24,-25,
            -25,-28,-28,-28,-28,-24,-21,-26,-24,-19,-19,-15,-14,-8,-5,-11,0,0,2,0,
            -4,-4,-9,-5,-2,-2,-5,-11,-12,-9,-7,-14,-18,-18,-21,-21,-16,-12,-9,-7,
            -14,-14,-12,-21,-22,-28,-31,-29,-24,-19,-25,-29,-28,-28,-28,-28,-28,-25,-24,-24,
            -24,-24,-18,-8,-2,-4,-4,-4,-5,-8,-9,-15,-15,-14,-14,-15,-16,-18,-15,-16,
            -5,-12,-11,-5,-8,-9,-12,-16,-16,-18,-21,-22,-24,-26,-22,-24,-22,-26,-31,-29 };


    std::ofstream outfile ("C:/Users/XXX/Thesis/RAM/RAM_speech_" + to_string(149) + ".mif");
    outfile << "WIDTH=32;" << std::endl;
    outfile << "DEPTH=160;" << std::endl;

    outfile << "ADDRESS_RADIX=DEC;" << std::endl;
    outfile << "DATA_RADIX=BIN;" << std::endl;
    outfile << endl;
    outfile << endl;
    outfile << "CONTENT BEGIN" << std::endl;
    outfile << endl;
    outfile << endl;

    outfile << vector_decimaltoBinary_string(speech,160);

    outfile << endl;
    outfile << endl;
    outfile << "END;" << std::endl;



    outfile.close();


    cout << "copied" << endl;
    cout << endl;

}

void writeBitsToFile(){

    std::ofstream outfile;//("C:/Users/Boopathy/OneDrive/Thesis/BITFILE/codec2_enc_bitfile.bit");
    outfile.open("C:/Users/Boopathy/OneDrive/Codec2_Thesis/hts2a_op/codec2_hts2A_verloig_bit_output_jan16.bit",ios::out | ios::app );


    unsigned char c1 = 0xF8;
    unsigned char c2 = 0x81;
    unsigned char c3 = 0xDD;
    unsigned char c4 = 0xD6;
    unsigned char c5 = 0xAA;
    unsigned char c6 = 0xC8;
    unsigned char c7 = 0xD1;
    unsigned char c8 = 0x40;
    unsigned char c9 = 0x91;
    unsigned char c10 = 0xD3;
    unsigned char c11 = 0x76;
    unsigned char c12 = 0xD8;
    unsigned char c13 = 0xC4;
    unsigned char c14 = 0x41;
    unsigned char c15 = 0x8D;
    unsigned char c16 = 0x73;
    unsigned char c17 = 0x77;
    unsigned char c18 = 0xC8;
    unsigned char c19 = 0xEE;
    unsigned char c20 = 0x41;
    unsigned char c21 = 0xCD;
    unsigned char c22 = 0xD7;
    unsigned char c23 = 0x72;
    unsigned char c24 = 0xC8;
    unsigned char c25 = 0xF4;
    unsigned char c26 = 0x41;
    unsigned char c27 = 0x8D;
    unsigned char c28 = 0xD6;
    unsigned char c29 = 0xB7;
    unsigned char c30 = 0xC8;
    unsigned char c31 = 0xD9;
    unsigned char c32 = 0xC0;
    unsigned char c33 = 0x89;
    unsigned char c34 = 0xD3;
    unsigned char c35 = 0x77;
    unsigned char c36 = 0xC8;
    unsigned char c37 = 0xC6;
    unsigned char c38 = 0x40;
    unsigned char c39 = 0xDD;
    unsigned char c40 = 0xD6;
    unsigned char c41 = 0xAB;
    unsigned char c42 = 0xC8;
    unsigned char c43 = 0xF9;
    unsigned char c44 = 0x40;
    unsigned char c45 = 0xD9;
    unsigned char c46 = 0xD7;
    unsigned char c47 = 0x77;
    unsigned char c48 = 0xC8;
    unsigned char c49 = 0xC4;
    unsigned char c50 = 0x40;
    unsigned char c51 = 0x41;
    unsigned char c52 = 0xD7;
    unsigned char c53 = 0x77;
    unsigned char c54 = 0xD8;
    unsigned char c55 = 0xFF;
    unsigned char c56 = 0x40;
    unsigned char c57 = 0xDD;
    unsigned char c58 = 0x9F;
    unsigned char c59 = 0x33;
    unsigned char c60 = 0x48;
    unsigned char c61 = 0xE5;
    unsigned char c62 = 0x80;
    unsigned char c63 = 0x49;
    unsigned char c64 = 0x97;
    unsigned char c65 = 0x73;
    unsigned char c66 = 0xC8;
    unsigned char c67 = 0xCC;
    unsigned char c68 = 0x40;
    unsigned char c69 = 0xCD;
    unsigned char c70 = 0xD7;
    unsigned char c71 = 0x33;
    unsigned char c72 = 0xD8;
    unsigned char c73 = 0xCF;
    unsigned char c74 = 0x40;
    unsigned char c75 = 0x40;
    unsigned char c76 = 0x15;
    unsigned char c77 = 0x31;
    unsigned char c78 = 0x6C;
    unsigned char c79 = 0xC4;
    unsigned char c80 = 0x84;
    unsigned char c81 = 0xC0;
    unsigned char c82 = 0x15;
    unsigned char c83 = 0x71;
    unsigned char c84 = 0x2C;
    unsigned char c85 = 0xD5;
    unsigned char c86 = 0xC0;
    unsigned char c87 = 0x00;
    unsigned char c88 = 0x1D;
    unsigned char c89 = 0x37;
    unsigned char c90 = 0x7C;
    unsigned char c91 = 0xD4;
    unsigned char c92 = 0xC4;
    unsigned char c93 = 0x59;
    unsigned char c94 = 0xD3;
    unsigned char c95 = 0x77;
    unsigned char c96 = 0x74;
    unsigned char c97 = 0xC9;
    unsigned char c98 = 0xD8;
    unsigned char c99 = 0x99;
    unsigned char c100 = 0xF2;
    unsigned char c101 = 0xB5;
    unsigned char c102 = 0x74;
    unsigned char c103 = 0xE1;
    unsigned char c104 = 0xDD;
    unsigned char c105 = 0x84;
    unsigned char c106 = 0x12;
    unsigned char c107 = 0x91;
    unsigned char c108 = 0x64;
    unsigned char c109 = 0xC9;
    unsigned char c110 = 0x33;
    unsigned char c111 = 0xF7;
    unsigned char c112 = 0x77;
    unsigned char c113 = 0x76;
    unsigned char c114 = 0xC8;
    unsigned char c115 = 0xDB;
    unsigned char c116 = 0xFB;
    unsigned char c117 = 0xF3;
    unsigned char c118 = 0x36;
    unsigned char c119 = 0xEA;
    unsigned char c120 = 0xC8;
    unsigned char c121 = 0xEA;
    unsigned char c122 = 0x58;
    unsigned char c123 = 0xC4;
    unsigned char c124 = 0x05;
    unsigned char c125 = 0x11;
    unsigned char c126 = 0x2C;
    unsigned char c127 = 0xC7;
    unsigned char c128 = 0x48;
    unsigned char c129 = 0xC0;
    unsigned char c130 = 0x45;
    unsigned char c131 = 0x17;
    unsigned char c132 = 0x6C;
    unsigned char c133 = 0xF2;
    unsigned char c134 = 0x48;
    unsigned char c135 = 0xC4;
    unsigned char c136 = 0x1B;
    unsigned char c137 = 0x11;
    unsigned char c138 = 0x74;
    unsigned char c139 = 0xF2;
    unsigned char c140 = 0x4C;
    unsigned char c141 = 0x84;
    unsigned char c142 = 0x03;
    unsigned char c143 = 0x53;
    unsigned char c144 = 0x64;
    unsigned char c145 = 0xD6;
    unsigned char c146 = 0x4D;
    unsigned char c147 = 0x84;
    unsigned char c148 = 0x03;
    unsigned char c149 = 0x55;
    unsigned char c150 = 0x64;
    unsigned char c151 = 0xC7;
    unsigned char c152 = 0x49;
    unsigned char c153 = 0x84;
    unsigned char c154 = 0x11;
    unsigned char c155 = 0x11;
    unsigned char c156 = 0x64;
    unsigned char c157 = 0xAA;
    unsigned char c158 = 0x48;
    unsigned char c159 = 0x84;
    unsigned char c160 = 0x33;
    unsigned char c161 = 0x13;
    unsigned char c162 = 0x64;
    unsigned char c163 = 0x0F;
    unsigned char c164 = 0x75;
    unsigned char c165 = 0x99;
    unsigned char c166 = 0xB3;
    unsigned char c167 = 0x37;
    unsigned char c168 = 0x74;
    unsigned char c169 = 0x36;
    unsigned char c170 = 0x7B;
    unsigned char c171 = 0x51;
    unsigned char c172 = 0x77;
    unsigned char c173 = 0x77;
    unsigned char c174 = 0x54;
    unsigned char c175 = 0x1D;
    unsigned char c176 = 0x89;
    unsigned char c177 = 0x85;
    unsigned char c178 = 0xB3;
    unsigned char c179 = 0x13;
    unsigned char c180 = 0x64;
    unsigned char c181 = 0x78;
    unsigned char c182 = 0x81;
    unsigned char c183 = 0xDD;
    unsigned char c184 = 0xD7;
    unsigned char c185 = 0x71;
    unsigned char c186 = 0x7C;
    unsigned char c187 = 0xA0;
    unsigned char c188 = 0x2F;
    unsigned char c189 = 0xE9;
    unsigned char c190 = 0x37;
    unsigned char c191 = 0x6B;
    unsigned char c192 = 0x64;
    unsigned char c193 = 0xBA;
    unsigned char c194 = 0xF3;
    unsigned char c195 = 0x31;
    unsigned char c196 = 0xF7;
    unsigned char c197 = 0x53;
    unsigned char c198 = 0x64;
    unsigned char c199 = 0xE2;
    unsigned char c200 = 0x15;
    unsigned char c201 = 0x0C;
    unsigned char c202 = 0x53;
    unsigned char c203 = 0x51;
    unsigned char c204 = 0x64;
    unsigned char c205 = 0xE6;
    unsigned char c206 = 0xF3;
    unsigned char c207 = 0x08;
    unsigned char c208 = 0x72;
    unsigned char c209 = 0xB1;
    unsigned char c210 = 0x24;
    unsigned char c211 = 0xE6;
    unsigned char c212 = 0xD3;
    unsigned char c213 = 0x18;
    unsigned char c214 = 0xF3;
    unsigned char c215 = 0x73;
    unsigned char c216 = 0x64;
    unsigned char c217 = 0xC4;
    unsigned char c218 = 0xD5;
    unsigned char c219 = 0x18;
    unsigned char c220 = 0xB3;
    unsigned char c221 = 0x71;
    unsigned char c222 = 0x24;
    unsigned char c223 = 0xF4;
    unsigned char c224 = 0xD5;
    unsigned char c225 = 0x08;
    unsigned char c226 = 0x93;
    unsigned char c227 = 0x71;
    unsigned char c228 = 0x64;
    unsigned char c229 = 0xF4;
    unsigned char c230 = 0xDD;
    unsigned char c231 = 0x48;
    unsigned char c232 = 0xAA;
    unsigned char c233 = 0xF1;
    unsigned char c234 = 0x64;
    unsigned char c235 = 0xC8;
    unsigned char c236 = 0xDD;
    unsigned char c237 = 0xCD;
    unsigned char c238 = 0xAA;
    unsigned char c239 = 0xF5;
    unsigned char c240 = 0x24;
    unsigned char c241 = 0xDC;
    unsigned char c242 = 0xDD;
    unsigned char c243 = 0x84;
    unsigned char c244 = 0xB6;
    unsigned char c245 = 0xF5;
    unsigned char c246 = 0x24;
    unsigned char c247 = 0xF8;
    unsigned char c248 = 0xD9;
    unsigned char c249 = 0x84;
    unsigned char c250 = 0x37;
    unsigned char c251 = 0x29;
    unsigned char c252 = 0x24;
    unsigned char c253 = 0xCB;
    unsigned char c254 = 0x59;
    unsigned char c255 = 0x84;
    unsigned char c256 = 0x2F;
    unsigned char c257 = 0x2B;
    unsigned char c258 = 0x24;
    unsigned char c259 = 0xC8;
    unsigned char c260 = 0xD9;
    unsigned char c261 = 0x84;
    unsigned char c262 = 0x2F;
    unsigned char c263 = 0x29;
    unsigned char c264 = 0x24;
    unsigned char c265 = 0xF8;
    unsigned char c266 = 0xD8;
    unsigned char c267 = 0x84;
    unsigned char c268 = 0x2F;
    unsigned char c269 = 0x35;
    unsigned char c270 = 0xA4;
    unsigned char c271 = 0xFD;
    unsigned char c272 = 0xD8;
    unsigned char c273 = 0xC4;
    unsigned char c274 = 0x36;
    unsigned char c275 = 0xB1;
    unsigned char c276 = 0xE4;
    unsigned char c277 = 0xC4;
    unsigned char c278 = 0xC8;
    unsigned char c279 = 0xD5;
    unsigned char c280 = 0x76;
    unsigned char c281 = 0xB7;
    unsigned char c282 = 0xF4;
    unsigned char c283 = 0xF5;
    unsigned char c284 = 0x8B;
    unsigned char c285 = 0x29;
    unsigned char c286 = 0x76;
    unsigned char c287 = 0xB7;
    unsigned char c288 = 0xF4;
    unsigned char c289 = 0x84;
    unsigned char c290 = 0x9F;
    unsigned char c291 = 0xED;
    unsigned char c292 = 0x6A;
    unsigned char c293 = 0xB3;
    unsigned char c294 = 0x74;
    unsigned char c295 = 0x27;
    unsigned char c296 = 0x55;
    unsigned char c297 = 0x9D;
    unsigned char c298 = 0x77;
    unsigned char c299 = 0x77;
    unsigned char c300 = 0x64;
    unsigned char c301 = 0xED;
    unsigned char c302 = 0x9D;
    unsigned char c303 = 0x84;
    unsigned char c304 = 0x33;
    unsigned char c305 = 0x57;
    unsigned char c306 = 0xEC;
    unsigned char c307 = 0xEF;
    unsigned char c308 = 0x3B;
    unsigned char c309 = 0x1D;
    unsigned char c310 = 0xF7;
    unsigned char c311 = 0x71;
    unsigned char c312 = 0x64;
    unsigned char c313 = 0xF9;
    unsigned char c314 = 0x79;
    unsigned char c315 = 0x1D;
    unsigned char c316 = 0x76;
    unsigned char c317 = 0xB3;
    unsigned char c318 = 0x24;
    unsigned char c319 = 0xE1;
    unsigned char c320 = 0xD1;
    unsigned char c321 = 0x49;
    unsigned char c322 = 0xB6;
    unsigned char c323 = 0xB1;
    unsigned char c324 = 0x24;
    unsigned char c325 = 0xE3;
    unsigned char c326 = 0x99;
    unsigned char c327 = 0x84;
    unsigned char c328 = 0x2A;
    unsigned char c329 = 0xB7;
    unsigned char c330 = 0x64;
    unsigned char c331 = 0xE1;
    unsigned char c332 = 0x8D;
    unsigned char c333 = 0x4C;
    unsigned char c334 = 0x97;
    unsigned char c335 = 0x71;
    unsigned char c336 = 0x7C;
    unsigned char c337 = 0xC1;
    unsigned char c338 = 0x85;
    unsigned char c339 = 0x1C;
    unsigned char c340 = 0x9F;
    unsigned char c341 = 0x33;
    unsigned char c342 = 0x7C;
    unsigned char c343 = 0xAB;
    unsigned char c344 = 0x4F;
    unsigned char c345 = 0x71;
    unsigned char c346 = 0x13;
    unsigned char c347 = 0x31;
    unsigned char c348 = 0x64;
    unsigned char c349 = 0x6C;
    unsigned char c350 = 0x27;
    unsigned char c351 = 0xF5;
    unsigned char c352 = 0x32;
    unsigned char c353 = 0xAB;
    unsigned char c354 = 0x54;
    unsigned char c355 = 0x17;
    unsigned char c356 = 0xEB;
    unsigned char c357 = 0xFB;
    unsigned char c358 = 0x33;
    unsigned char c359 = 0x33;
    unsigned char c360 = 0xD4;
    unsigned char c361 = 0x33;
    unsigned char c362 = 0x67;
    unsigned char c363 = 0xFB;
    unsigned char c364 = 0x72;
    unsigned char c365 = 0xF2;
    unsigned char c366 = 0xD4;
    unsigned char c367 = 0x38;
    unsigned char c368 = 0x77;
    unsigned char c369 = 0xBF;
    unsigned char c370 = 0x73;
    unsigned char c371 = 0x2E;
    unsigned char c372 = 0xF4;
    unsigned char c373 = 0x62;
    unsigned char c374 = 0x1C;
    unsigned char c375 = 0x8C;
    unsigned char c376 = 0xB7;
    unsigned char c377 = 0x37;
    unsigned char c378 = 0x64;
    unsigned char c379 = 0xC4;
    unsigned char c380 = 0xD4;
    unsigned char c381 = 0x85;
    unsigned char c382 = 0xAF;
    unsigned char c383 = 0x2B;
    unsigned char c384 = 0x24;
    unsigned char c385 = 0xB1;
    unsigned char c386 = 0x48;
    unsigned char c387 = 0x80;
    unsigned char c388 = 0x33;
    unsigned char c389 = 0x29;
    unsigned char c390 = 0x5C;
    unsigned char c391 = 0xF6;
    unsigned char c392 = 0x95;
    unsigned char c393 = 0x95;
    unsigned char c394 = 0x73;
    unsigned char c395 = 0x37;
    unsigned char c396 = 0x5C;
    unsigned char c397 = 0xA1;
    unsigned char c398 = 0xD7;
    unsigned char c399 = 0x6D;
    unsigned char c400 = 0x2A;
    unsigned char c401 = 0xF1;
    unsigned char c402 = 0xF4;
    unsigned char c403 = 0x0F;
    unsigned char c404 = 0xF7;
    unsigned char c405 = 0x73;
    unsigned char c406 = 0x32;
    unsigned char c407 = 0xE9;
    unsigned char c408 = 0x74;
    unsigned char c409 = 0x71;
    unsigned char c410 = 0x89;
    unsigned char c411 = 0xCC;
    unsigned char c412 = 0xEE;
    unsigned char c413 = 0xF5;
    unsigned char c414 = 0x74;
    unsigned char c415 = 0xFC;
    unsigned char c416 = 0xD5;
    unsigned char c417 = 0x84;
    unsigned char c418 = 0x56;
    unsigned char c419 = 0x91;
    unsigned char c420 = 0x24;
    unsigned char c421 = 0xFD;
    unsigned char c422 = 0x48;
    unsigned char c423 = 0xC4;
    unsigned char c424 = 0x05;
    unsigned char c425 = 0x11;
    unsigned char c426 = 0x2C;
    unsigned char c427 = 0xF4;
    unsigned char c428 = 0xC8;
    unsigned char c429 = 0xC0;
    unsigned char c430 = 0x45;
    unsigned char c431 = 0x17;
    unsigned char c432 = 0x6C;
    unsigned char c433 = 0xED;
    unsigned char c434 = 0xD8;
    unsigned char c435 = 0xC4;
    unsigned char c436 = 0x1B;
    unsigned char c437 = 0x11;
    unsigned char c438 = 0x74;
    unsigned char c439 = 0xDD;
    unsigned char c440 = 0xDC;
    unsigned char c441 = 0x84;
    unsigned char c442 = 0x03;
    unsigned char c443 = 0x53;
    unsigned char c444 = 0x64;
    unsigned char c445 = 0xF4;
    unsigned char c446 = 0xDD;
    unsigned char c447 = 0x84;
    unsigned char c448 = 0x03;
    unsigned char c449 = 0x55;
    unsigned char c450 = 0x64;
    unsigned char c451 = 0xFB;
    unsigned char c452 = 0x59;
    unsigned char c453 = 0x84;
    unsigned char c454 = 0x11;
    unsigned char c455 = 0x11;
    unsigned char c456 = 0x64;
    unsigned char c457 = 0xC4;
    unsigned char c458 = 0xC8;
    unsigned char c459 = 0x84;
    unsigned char c460 = 0x33;
    unsigned char c461 = 0x13;
    unsigned char c462 = 0x64;
    unsigned char c463 = 0xD5;
    unsigned char c464 = 0xC5;
    unsigned char c465 = 0x99;
    unsigned char c466 = 0xB3;
    unsigned char c467 = 0x37;
    unsigned char c468 = 0x74;
    unsigned char c469 = 0xD7;
    unsigned char c470 = 0x4B;
    unsigned char c471 = 0x51;
    unsigned char c472 = 0x77;
    unsigned char c473 = 0x77;
    unsigned char c474 = 0x54;
    unsigned char c475 = 0x59;
    unsigned char c476 = 0x99;
    unsigned char c477 = 0x85;
    unsigned char c478 = 0xB3;
    unsigned char c479 = 0x13;
    unsigned char c480 = 0x64;
    unsigned char c481 = 0xE6;
    unsigned char c482 = 0xD9;
    unsigned char c483 = 0xC4;
    unsigned char c484 = 0x15;
    unsigned char c485 = 0x31;
    unsigned char c486 = 0x24;
    unsigned char c487 = 0xDD;
    unsigned char c488 = 0xD5;
    unsigned char c489 = 0xC4;
    unsigned char c490 = 0x15;
    unsigned char c491 = 0x75;
    unsigned char c492 = 0x34;
    unsigned char c493 = 0xDC;
    unsigned char c494 = 0xDD;
    unsigned char c495 = 0x84;
    unsigned char c496 = 0x9D;
    unsigned char c497 = 0xF0;
    unsigned char c498 = 0xA4;
    unsigned char c499 = 0xE5;
    unsigned char c500 = 0xD8;
    unsigned char c501 = 0x84;
    unsigned char c502 = 0x19;
    unsigned char c503 = 0xB0;
    unsigned char c504 = 0xF4;
    unsigned char c505 = 0xFB;
    unsigned char c506 = 0x48;
    unsigned char c507 = 0x80;
    unsigned char c508 = 0xC9;
    unsigned char c509 = 0x94;
    unsigned char c510 = 0xE4;
    unsigned char c511 = 0xCD;
    unsigned char c512 = 0xC8;
    unsigned char c513 = 0x40;
    unsigned char c514 = 0x0D;
    unsigned char c515 = 0x94;
    unsigned char c516 = 0xE4;
    unsigned char c517 = 0xFB;
    unsigned char c518 = 0x48;
    unsigned char c519 = 0x40;
    unsigned char c520 = 0x09;
    unsigned char c521 = 0x9C;
    unsigned char c522 = 0xE4;
    unsigned char c523 = 0xFB;
    unsigned char c524 = 0x48;
    unsigned char c525 = 0x40;
    unsigned char c526 = 0x0D;
    unsigned char c527 = 0x94;
    unsigned char c528 = 0xEC;
    unsigned char c529 = 0xE0;
    unsigned char c530 = 0xC8;
    unsigned char c531 = 0x44;
    unsigned char c532 = 0x89;
    unsigned char c533 = 0x9C;
    unsigned char c534 = 0x84;
    unsigned char c535 = 0xD4;
    unsigned char c536 = 0xD8;
    unsigned char c537 = 0x84;
    unsigned char c538 = 0x5D;
    unsigned char c539 = 0xD4;
    unsigned char c540 = 0xE4;
    unsigned char c541 = 0xF5;
    unsigned char c542 = 0xDD;
    unsigned char c543 = 0x44;
    unsigned char c544 = 0x53;
    unsigned char c545 = 0x35;
    unsigned char c546 = 0x64;
    unsigned char c547 = 0xC5;
    unsigned char c548 = 0xD1;
    unsigned char c549 = 0x04;
    unsigned char c550 = 0xD3;
    unsigned char c551 = 0x71;
    unsigned char c552 = 0x24;
    unsigned char c553 = 0xFE;
    unsigned char c554 = 0x55;
    unsigned char c555 = 0x04;
    unsigned char c556 = 0xD2;
    unsigned char c557 = 0xF3;
    unsigned char c558 = 0x64;
    unsigned char c559 = 0xFE;
    unsigned char c560 = 0x55;
    unsigned char c561 = 0x4C;
    unsigned char c562 = 0x72;
    unsigned char c563 = 0xF5;
    unsigned char c564 = 0x64;
    unsigned char c565 = 0xF8;
    unsigned char c566 = 0xD5;
    unsigned char c567 = 0x4C;
    unsigned char c568 = 0x76;
    unsigned char c569 = 0xF5;
    unsigned char c570 = 0x64;
    unsigned char c571 = 0xE6;
    unsigned char c572 = 0x5D;
    unsigned char c573 = 0x8C;
    unsigned char c574 = 0x72;
    unsigned char c575 = 0xF7;
    unsigned char c576 = 0x64;
    unsigned char c577 = 0xE0;
    unsigned char c578 = 0xDD;
    unsigned char c579 = 0x8C;
    unsigned char c580 = 0x76;
    unsigned char c581 = 0xE9;
    unsigned char c582 = 0x64;
    unsigned char c583 = 0xCE;
    unsigned char c584 = 0x55;
    unsigned char c585 = 0x8C;
    unsigned char c586 = 0x76;
    unsigned char c587 = 0xF5;
    unsigned char c588 = 0x64;
    unsigned char c589 = 0xE0;
    unsigned char c590 = 0xD5;
    unsigned char c591 = 0x8C;
    unsigned char c592 = 0x73;
    unsigned char c593 = 0x35;
    unsigned char c594 = 0x64;
    unsigned char c595 = 0xD3;
    unsigned char c596 = 0x5C;
    unsigned char c597 = 0x84;
    unsigned char c598 = 0xF2;
    unsigned char c599 = 0xB1;
    unsigned char c600 = 0x64;
    unsigned char c601 = 0xF6;
    unsigned char c602 = 0x88;
    unsigned char c603 = 0xC4;
    unsigned char c604 = 0x05;
    unsigned char c605 = 0x11;
    unsigned char c606 = 0x2C;
    unsigned char c607 = 0xD0;
    unsigned char c608 = 0x88;
    unsigned char c609 = 0xC0;
    unsigned char c610 = 0x45;
    unsigned char c611 = 0x17;
    unsigned char c612 = 0x6C;
    unsigned char c613 = 0xD3;
    unsigned char c614 = 0x48;
    unsigned char c615 = 0xC4;
    unsigned char c616 = 0x1B;
    unsigned char c617 = 0x11;
    unsigned char c618 = 0x74;
    unsigned char c619 = 0xE3;
    unsigned char c620 = 0xCC;
    unsigned char c621 = 0x84;
    unsigned char c622 = 0x03;
    unsigned char c623 = 0x53;
    unsigned char c624 = 0x64;
    unsigned char c625 = 0xEC;
    unsigned char c626 = 0xCD;
    unsigned char c627 = 0x84;
    unsigned char c628 = 0x03;
    unsigned char c629 = 0x55;
    unsigned char c630 = 0x64;
    unsigned char c631 = 0x65;
    unsigned char c632 = 0x29;
    unsigned char c633 = 0x84;
    unsigned char c634 = 0x11;
    unsigned char c635 = 0x11;
    unsigned char c636 = 0x64;
    unsigned char c637 = 0x0B;
    unsigned char c638 = 0x98;
    unsigned char c639 = 0x84;
    unsigned char c640 = 0x33;
    unsigned char c641 = 0x13;
    unsigned char c642 = 0x64;
    unsigned char c643 = 0xE8;
    unsigned char c644 = 0xD5;
    unsigned char c645 = 0x99;
    unsigned char c646 = 0xB3;
    unsigned char c647 = 0x37;
    unsigned char c648 = 0x74;
    unsigned char c649 = 0xDD;
    unsigned char c650 = 0xDB;
    unsigned char c651 = 0x51;
    unsigned char c652 = 0x77;
    unsigned char c653 = 0x77;
    unsigned char c654 = 0x54;
    unsigned char c655 = 0xF4;
    unsigned char c656 = 0xD9;
    unsigned char c657 = 0x85;
    unsigned char c658 = 0xB3;
    unsigned char c659 = 0x13;
    unsigned char c660 = 0x64;
    unsigned char c661 = 0xF4;
    unsigned char c662 = 0xD8;
    unsigned char c663 = 0x84;
    unsigned char c664 = 0x73;
    unsigned char c665 = 0x29;
    unsigned char c666 = 0x64;
    unsigned char c667 = 0xF4;
    unsigned char c668 = 0xDD;
    unsigned char c669 = 0x8D;
    unsigned char c670 = 0xAB;
    unsigned char c671 = 0x2B;
    unsigned char c672 = 0x74;
    unsigned char c673 = 0x5B;
    unsigned char c674 = 0x8C;
    unsigned char c675 = 0xC4;
    unsigned char c676 = 0x2B;
    unsigned char c677 = 0x6B;
    unsigned char c678 = 0x74;
    unsigned char c679 = 0xD2;
    unsigned char c680 = 0x4B;
    unsigned char c681 = 0x51;
    unsigned char c682 = 0xEB;
    unsigned char c683 = 0x37;
    unsigned char c684 = 0x74;
    unsigned char c685 = 0x2E;
    unsigned char c686 = 0x16;
    unsigned char c687 = 0xAF;
    unsigned char c688 = 0x6E;
    unsigned char c689 = 0xEE;
    unsigned char c690 = 0xF4;
    unsigned char c691 = 0x05;
    unsigned char c692 = 0xD3;
    unsigned char c693 = 0xFA;
    unsigned char c694 = 0xB3;
    unsigned char c695 = 0x2F;
    unsigned char c696 = 0xDC;
    unsigned char c697 = 0x03;
    unsigned char c698 = 0x77;
    unsigned char c699 = 0xFE;
    unsigned char c700 = 0xF7;
    unsigned char c701 = 0x72;
    unsigned char c702 = 0xDC;
    unsigned char c703 = 0x0D;
    unsigned char c704 = 0xBF;
    unsigned char c705 = 0xFF;
    unsigned char c706 = 0x37;
    unsigned char c707 = 0x32;
    unsigned char c708 = 0xCC;
    unsigned char c709 = 0x02;
    unsigned char c710 = 0x67;
    unsigned char c711 = 0xFE;
    unsigned char c712 = 0xB7;
    unsigned char c713 = 0x72;
    unsigned char c714 = 0xDC;
    unsigned char c715 = 0x03;
    unsigned char c716 = 0x67;
    unsigned char c717 = 0xFF;
    unsigned char c718 = 0x33;
    unsigned char c719 = 0x32;
    unsigned char c720 = 0xCC;
    unsigned char c721 = 0x06;
    unsigned char c722 = 0x6B;
    unsigned char c723 = 0xFE;
    unsigned char c724 = 0xF3;
    unsigned char c725 = 0x3A;
    unsigned char c726 = 0x5C;
    unsigned char c727 = 0x2B;
    unsigned char c728 = 0xEF;
    unsigned char c729 = 0xFF;
    unsigned char c730 = 0x33;
    unsigned char c731 = 0x36;
    unsigned char c732 = 0x5C;
    unsigned char c733 = 0x15;
    unsigned char c734 = 0xAB;
    unsigned char c735 = 0xFF;
    unsigned char c736 = 0x2E;
    unsigned char c737 = 0xF6;
    unsigned char c738 = 0xD4;
    unsigned char c739 = 0x1B;
    unsigned char c740 = 0x6F;
    unsigned char c741 = 0xFF;
    unsigned char c742 = 0x2F;
    unsigned char c743 = 0x73;
    unsigned char c744 = 0xF4;
    unsigned char c745 = 0x3A;
    unsigned char c746 = 0x7F;
    unsigned char c747 = 0x3A;
    unsigned char c748 = 0xAA;
    unsigned char c749 = 0xF3;
    unsigned char c750 = 0xF4;
    unsigned char c751 = 0x99;
    unsigned char c752 = 0x76;
    unsigned char c753 = 0xB7;
    unsigned char c754 = 0x2B;
    unsigned char c755 = 0x73;
    unsigned char c756 = 0xE4;
    unsigned char c757 = 0x23;
    unsigned char c758 = 0x8B;
    unsigned char c759 = 0x11;
    unsigned char c760 = 0xF7;
    unsigned char c761 = 0x73;
    unsigned char c762 = 0x24;
    unsigned char c763 = 0x25;
    unsigned char c764 = 0xDA;
    unsigned char c765 = 0x91;
    unsigned char c766 = 0xD3;
    unsigned char c767 = 0x2B;
    unsigned char c768 = 0x64;
    unsigned char c769 = 0x2E;
    unsigned char c770 = 0x46;
    unsigned char c771 = 0xD1;
    unsigned char c772 = 0x11;
    unsigned char c773 = 0x2B;
    unsigned char c774 = 0x64;
    unsigned char c775 = 0x58;
    unsigned char c776 = 0x4A;
    unsigned char c777 = 0xD5;
    unsigned char c778 = 0xD5;
    unsigned char c779 = 0x6B;
    unsigned char c780 = 0xEC;
    unsigned char c781 = 0xE8;
    unsigned char c782 = 0x5F;
    unsigned char c783 = 0x59;
    unsigned char c784 = 0xDD;
    unsigned char c785 = 0x73;
    unsigned char c786 = 0x7C;
    unsigned char c787 = 0x99;
    unsigned char c788 = 0x9B;
    unsigned char c789 = 0x51;
    unsigned char c790 = 0x5D;
    unsigned char c791 = 0x6E;
    unsigned char c792 = 0xDC;
    unsigned char c793 = 0xE2;
    unsigned char c794 = 0x41;
    unsigned char c795 = 0x1D;
    unsigned char c796 = 0x9D;
    unsigned char c797 = 0x77;
    unsigned char c798 = 0x5C;
    unsigned char c799 = 0xDE;
    unsigned char c800 = 0x41;
    unsigned char c801 = 0x1D;
    unsigned char c802 = 0xDD;
    unsigned char c803 = 0x37;
    unsigned char c804 = 0x5C;
    unsigned char c805 = 0xC5;
    unsigned char c806 = 0x43;
    unsigned char c807 = 0x14;
    unsigned char c808 = 0xDD;
    unsigned char c809 = 0x33;
    unsigned char c810 = 0x78;
    unsigned char c811 = 0xFE;
    unsigned char c812 = 0x82;
    unsigned char c813 = 0x94;
    unsigned char c814 = 0xD7;
    unsigned char c815 = 0x73;
    unsigned char c816 = 0x58;
    unsigned char c817 = 0xD0;
    unsigned char c818 = 0x43;
    unsigned char c819 = 0x14;
    unsigned char c820 = 0x9D;
    unsigned char c821 = 0x33;
    unsigned char c822 = 0x78;
    unsigned char c823 = 0xC3;
    unsigned char c824 = 0x81;
    unsigned char c825 = 0x5D;
    unsigned char c826 = 0x97;
    unsigned char c827 = 0x33;
    unsigned char c828 = 0x7C;
    unsigned char c829 = 0xC4;
    unsigned char c830 = 0xC1;
    unsigned char c831 = 0xDD;
    unsigned char c832 = 0xD7;
    unsigned char c833 = 0x77;
    unsigned char c834 = 0x7C;
    unsigned char c835 = 0xD5;
    unsigned char c836 = 0xC0;
    unsigned char c837 = 0x89;
    unsigned char c838 = 0xD7;
    unsigned char c839 = 0x33;
    unsigned char c840 = 0xD8;
    unsigned char c841 = 0xDD;
    unsigned char c842 = 0x41;
    unsigned char c843 = 0x99;
    unsigned char c844 = 0xDF;
    unsigned char c845 = 0x33;
    unsigned char c846 = 0x78;
    unsigned char c847 = 0xCB;
    unsigned char c848 = 0x40;
    unsigned char c849 = 0x9D;
    unsigned char c850 = 0xD7;
    unsigned char c851 = 0x71;
    unsigned char c852 = 0x6C;
    unsigned char c853 = 0xC8;
    unsigned char c854 = 0x41;
    unsigned char c855 = 0x9D;
    unsigned char c856 = 0xD7;
    unsigned char c857 = 0x71;
    unsigned char c858 = 0x48;
    unsigned char c859 = 0xED;
    unsigned char c860 = 0x40;
    unsigned char c861 = 0xDD;
    unsigned char c862 = 0x9D;
    unsigned char c863 = 0x33;
    unsigned char c864 = 0xC8;
    unsigned char c865 = 0xC1;
    unsigned char c866 = 0x80;
    unsigned char c867 = 0xDD;
    unsigned char c868 = 0x9F;
    unsigned char c869 = 0x77;
    unsigned char c870 = 0xC8;
    unsigned char c871 = 0xD0;
    unsigned char c872 = 0x40;
    unsigned char c873 = 0xD5;
    unsigned char c874 = 0xD3;
    unsigned char c875 = 0x77;
    unsigned char c876 = 0xC8;
    unsigned char c877 = 0xFC;
    unsigned char c878 = 0x41;
    unsigned char c879 = 0x91;
    unsigned char c880 = 0x53;
    unsigned char c881 = 0x76;
    unsigned char c882 = 0xC8;
    unsigned char c883 = 0xD8;
    unsigned char c884 = 0x41;
    unsigned char c885 = 0xC9;
    unsigned char c886 = 0x57;
    unsigned char c887 = 0x77;
    unsigned char c888 = 0xC8;
    unsigned char c889 = 0xE5;
    unsigned char c890 = 0xC0;
    unsigned char c891 = 0x5D;
    unsigned char c892 = 0xD7;
    unsigned char c893 = 0x6A;
    unsigned char c894 = 0xC8;
    unsigned char c895 = 0xE5;
    unsigned char c896 = 0xC0;
    unsigned char c897 = 0xDD;
    unsigned char c898 = 0xD6;
    unsigned char c899 = 0xB7;
    unsigned char c900 = 0x48;


    outfile << c1;
    outfile << c2;
    outfile << c3;
    outfile << c4;
    outfile << c5;
    outfile << c6;
    outfile << c7;
    outfile << c8;
    outfile << c9;
    outfile << c10;
    outfile << c11;
    outfile << c12;
    outfile << c13;
    outfile << c14;
    outfile << c15;
    outfile << c16;
    outfile << c17;
    outfile << c18;
    outfile << c19;
    outfile << c20;
    outfile << c21;
    outfile << c22;
    outfile << c23;
    outfile << c24;
    outfile << c25;
    outfile << c26;
    outfile << c27;
    outfile << c28;
    outfile << c29;
    outfile << c30;
    outfile << c31;
    outfile << c32;
    outfile << c33;
    outfile << c34;
    outfile << c35;
    outfile << c36;
    outfile << c37;
    outfile << c38;
    outfile << c39;
    outfile << c40;
    outfile << c41;
    outfile << c42;
    outfile << c43;
    outfile << c44;
    outfile << c45;
    outfile << c46;
    outfile << c47;
    outfile << c48;
    outfile << c49;
    outfile << c50;
    outfile << c51;
    outfile << c52;
    outfile << c53;
    outfile << c54;
    outfile << c55;
    outfile << c56;
    outfile << c57;
    outfile << c58;
    outfile << c59;
    outfile << c60;
    outfile << c61;
    outfile << c62;
    outfile << c63;
    outfile << c64;
    outfile << c65;
    outfile << c66;
    outfile << c67;
    outfile << c68;
    outfile << c69;
    outfile << c70;
    outfile << c71;
    outfile << c72;
    outfile << c73;
    outfile << c74;
    outfile << c75;
    outfile << c76;
    outfile << c77;
    outfile << c78;
    outfile << c79;
    outfile << c80;
    outfile << c81;
    outfile << c82;
    outfile << c83;
    outfile << c84;
    outfile << c85;
    outfile << c86;
    outfile << c87;
    outfile << c88;
    outfile << c89;
    outfile << c90;
    outfile << c91;
    outfile << c92;
    outfile << c93;
    outfile << c94;
    outfile << c95;
    outfile << c96;
    outfile << c97;
    outfile << c98;
    outfile << c99;
    outfile << c100;
    outfile << c101;
    outfile << c102;
    outfile << c103;
    outfile << c104;
    outfile << c105;
    outfile << c106;
    outfile << c107;
    outfile << c108;
    outfile << c109;
    outfile << c110;
    outfile << c111;
    outfile << c112;
    outfile << c113;
    outfile << c114;
    outfile << c115;
    outfile << c116;
    outfile << c117;
    outfile << c118;
    outfile << c119;
    outfile << c120;
    outfile << c121;
    outfile << c122;
    outfile << c123;
    outfile << c124;
    outfile << c125;
    outfile << c126;
    outfile << c127;
    outfile << c128;
    outfile << c129;
    outfile << c130;
    outfile << c131;
    outfile << c132;
    outfile << c133;
    outfile << c134;
    outfile << c135;
    outfile << c136;
    outfile << c137;
    outfile << c138;
    outfile << c139;
    outfile << c140;
    outfile << c141;
    outfile << c142;
    outfile << c143;
    outfile << c144;
    outfile << c145;
    outfile << c146;
    outfile << c147;
    outfile << c148;
    outfile << c149;
    outfile << c150;
    outfile << c151;
    outfile << c152;
    outfile << c153;
    outfile << c154;
    outfile << c155;
    outfile << c156;
    outfile << c157;
    outfile << c158;
    outfile << c159;
    outfile << c160;
    outfile << c161;
    outfile << c162;
    outfile << c163;
    outfile << c164;
    outfile << c165;
    outfile << c166;
    outfile << c167;
    outfile << c168;
    outfile << c169;
    outfile << c170;
    outfile << c171;
    outfile << c172;
    outfile << c173;
    outfile << c174;
    outfile << c175;
    outfile << c176;
    outfile << c177;
    outfile << c178;
    outfile << c179;
    outfile << c180;
    outfile << c181;
    outfile << c182;
    outfile << c183;
    outfile << c184;
    outfile << c185;
    outfile << c186;
    outfile << c187;
    outfile << c188;
    outfile << c189;
    outfile << c190;
    outfile << c191;
    outfile << c192;
    outfile << c193;
    outfile << c194;
    outfile << c195;
    outfile << c196;
    outfile << c197;
    outfile << c198;
    outfile << c199;
    outfile << c200;
    outfile << c201;
    outfile << c202;
    outfile << c203;
    outfile << c204;
    outfile << c205;
    outfile << c206;
    outfile << c207;
    outfile << c208;
    outfile << c209;
    outfile << c210;
    outfile << c211;
    outfile << c212;
    outfile << c213;
    outfile << c214;
    outfile << c215;
    outfile << c216;
    outfile << c217;
    outfile << c218;
    outfile << c219;
    outfile << c220;
    outfile << c221;
    outfile << c222;
    outfile << c223;
    outfile << c224;
    outfile << c225;
    outfile << c226;
    outfile << c227;
    outfile << c228;
    outfile << c229;
    outfile << c230;
    outfile << c231;
    outfile << c232;
    outfile << c233;
    outfile << c234;
    outfile << c235;
    outfile << c236;
    outfile << c237;
    outfile << c238;
    outfile << c239;
    outfile << c240;
    outfile << c241;
    outfile << c242;
    outfile << c243;
    outfile << c244;
    outfile << c245;
    outfile << c246;
    outfile << c247;
    outfile << c248;
    outfile << c249;
    outfile << c250;
    outfile << c251;
    outfile << c252;
    outfile << c253;
    outfile << c254;
    outfile << c255;
    outfile << c256;
    outfile << c257;
    outfile << c258;
    outfile << c259;
    outfile << c260;
    outfile << c261;
    outfile << c262;
    outfile << c263;
    outfile << c264;
    outfile << c265;
    outfile << c266;
    outfile << c267;
    outfile << c268;
    outfile << c269;
    outfile << c270;
    outfile << c271;
    outfile << c272;
    outfile << c273;
    outfile << c274;
    outfile << c275;
    outfile << c276;
    outfile << c277;
    outfile << c278;
    outfile << c279;
    outfile << c280;
    outfile << c281;
    outfile << c282;
    outfile << c283;
    outfile << c284;
    outfile << c285;
    outfile << c286;
    outfile << c287;
    outfile << c288;
    outfile << c289;
    outfile << c290;
    outfile << c291;
    outfile << c292;
    outfile << c293;
    outfile << c294;
    outfile << c295;
    outfile << c296;
    outfile << c297;
    outfile << c298;
    outfile << c299;
    outfile << c300;
    outfile << c301;
    outfile << c302;
    outfile << c303;
    outfile << c304;
    outfile << c305;
    outfile << c306;
    outfile << c307;
    outfile << c308;
    outfile << c309;
    outfile << c310;
    outfile << c311;
    outfile << c312;
    outfile << c313;
    outfile << c314;
    outfile << c315;
    outfile << c316;
    outfile << c317;
    outfile << c318;
    outfile << c319;
    outfile << c320;
    outfile << c321;
    outfile << c322;
    outfile << c323;
    outfile << c324;
    outfile << c325;
    outfile << c326;
    outfile << c327;
    outfile << c328;
    outfile << c329;
    outfile << c330;
    outfile << c331;
    outfile << c332;
    outfile << c333;
    outfile << c334;
    outfile << c335;
    outfile << c336;
    outfile << c337;
    outfile << c338;
    outfile << c339;
    outfile << c340;
    outfile << c341;
    outfile << c342;
    outfile << c343;
    outfile << c344;
    outfile << c345;
    outfile << c346;
    outfile << c347;
    outfile << c348;
    outfile << c349;
    outfile << c350;
    outfile << c351;
    outfile << c352;
    outfile << c353;
    outfile << c354;
    outfile << c355;
    outfile << c356;
    outfile << c357;
    outfile << c358;
    outfile << c359;
    outfile << c360;
    outfile << c361;
    outfile << c362;
    outfile << c363;
    outfile << c364;
    outfile << c365;
    outfile << c366;
    outfile << c367;
    outfile << c368;
    outfile << c369;
    outfile << c370;
    outfile << c371;
    outfile << c372;
    outfile << c373;
    outfile << c374;
    outfile << c375;
    outfile << c376;
    outfile << c377;
    outfile << c378;
    outfile << c379;
    outfile << c380;
    outfile << c381;
    outfile << c382;
    outfile << c383;
    outfile << c384;
    outfile << c385;
    outfile << c386;
    outfile << c387;
    outfile << c388;
    outfile << c389;
    outfile << c390;
    outfile << c391;
    outfile << c392;
    outfile << c393;
    outfile << c394;
    outfile << c395;
    outfile << c396;
    outfile << c397;
    outfile << c398;
    outfile << c399;
    outfile << c400;
    outfile << c401;
    outfile << c402;
    outfile << c403;
    outfile << c404;
    outfile << c405;
    outfile << c406;
    outfile << c407;
    outfile << c408;
    outfile << c409;
    outfile << c410;
    outfile << c411;
    outfile << c412;
    outfile << c413;
    outfile << c414;
    outfile << c415;
    outfile << c416;
    outfile << c417;
    outfile << c418;
    outfile << c419;
    outfile << c420;
    outfile << c421;
    outfile << c422;
    outfile << c423;
    outfile << c424;
    outfile << c425;
    outfile << c426;
    outfile << c427;
    outfile << c428;
    outfile << c429;
    outfile << c430;
    outfile << c431;
    outfile << c432;
    outfile << c433;
    outfile << c434;
    outfile << c435;
    outfile << c436;
    outfile << c437;
    outfile << c438;
    outfile << c439;
    outfile << c440;
    outfile << c441;
    outfile << c442;
    outfile << c443;
    outfile << c444;
    outfile << c445;
    outfile << c446;
    outfile << c447;
    outfile << c448;
    outfile << c449;
    outfile << c450;
    outfile << c451;
    outfile << c452;
    outfile << c453;
    outfile << c454;
    outfile << c455;
    outfile << c456;
    outfile << c457;
    outfile << c458;
    outfile << c459;
    outfile << c460;
    outfile << c461;
    outfile << c462;
    outfile << c463;
    outfile << c464;
    outfile << c465;
    outfile << c466;
    outfile << c467;
    outfile << c468;
    outfile << c469;
    outfile << c470;
    outfile << c471;
    outfile << c472;
    outfile << c473;
    outfile << c474;
    outfile << c475;
    outfile << c476;
    outfile << c477;
    outfile << c478;
    outfile << c479;
    outfile << c480;
    outfile << c481;
    outfile << c482;
    outfile << c483;
    outfile << c484;
    outfile << c485;
    outfile << c486;
    outfile << c487;
    outfile << c488;
    outfile << c489;
    outfile << c490;
    outfile << c491;
    outfile << c492;
    outfile << c493;
    outfile << c494;
    outfile << c495;
    outfile << c496;
    outfile << c497;
    outfile << c498;
    outfile << c499;
    outfile << c500;
    outfile << c501;
    outfile << c502;
    outfile << c503;
    outfile << c504;
    outfile << c505;
    outfile << c506;
    outfile << c507;
    outfile << c508;
    outfile << c509;
    outfile << c510;
    outfile << c511;
    outfile << c512;
    outfile << c513;
    outfile << c514;
    outfile << c515;
    outfile << c516;
    outfile << c517;
    outfile << c518;
    outfile << c519;
    outfile << c520;
    outfile << c521;
    outfile << c522;
    outfile << c523;
    outfile << c524;
    outfile << c525;
    outfile << c526;
    outfile << c527;
    outfile << c528;
    outfile << c529;
    outfile << c530;
    outfile << c531;
    outfile << c532;
    outfile << c533;
    outfile << c534;
    outfile << c535;
    outfile << c536;
    outfile << c537;
    outfile << c538;
    outfile << c539;
    outfile << c540;
    outfile << c541;
    outfile << c542;
    outfile << c543;
    outfile << c544;
    outfile << c545;
    outfile << c546;
    outfile << c547;
    outfile << c548;
    outfile << c549;
    outfile << c550;
    outfile << c551;
    outfile << c552;
    outfile << c553;
    outfile << c554;
    outfile << c555;
    outfile << c556;
    outfile << c557;
    outfile << c558;
    outfile << c559;
    outfile << c560;
    outfile << c561;
    outfile << c562;
    outfile << c563;
    outfile << c564;
    outfile << c565;
    outfile << c566;
    outfile << c567;
    outfile << c568;
    outfile << c569;
    outfile << c570;
    outfile << c571;
    outfile << c572;
    outfile << c573;
    outfile << c574;
    outfile << c575;
    outfile << c576;
    outfile << c577;
    outfile << c578;
    outfile << c579;
    outfile << c580;
    outfile << c581;
    outfile << c582;
    outfile << c583;
    outfile << c584;
    outfile << c585;
    outfile << c586;
    outfile << c587;
    outfile << c588;
    outfile << c589;
    outfile << c590;
    outfile << c591;
    outfile << c592;
    outfile << c593;
    outfile << c594;
    outfile << c595;
    outfile << c596;
    outfile << c597;
    outfile << c598;
    outfile << c599;
    outfile << c600;
    outfile << c601;
    outfile << c602;
    outfile << c603;
    outfile << c604;
    outfile << c605;
    outfile << c606;
    outfile << c607;
    outfile << c608;
    outfile << c609;
    outfile << c610;
    outfile << c611;
    outfile << c612;
    outfile << c613;
    outfile << c614;
    outfile << c615;
    outfile << c616;
    outfile << c617;
    outfile << c618;
    outfile << c619;
    outfile << c620;
    outfile << c621;
    outfile << c622;
    outfile << c623;
    outfile << c624;
    outfile << c625;
    outfile << c626;
    outfile << c627;
    outfile << c628;
    outfile << c629;
    outfile << c630;
    outfile << c631;
    outfile << c632;
    outfile << c633;
    outfile << c634;
    outfile << c635;
    outfile << c636;
    outfile << c637;
    outfile << c638;
    outfile << c639;
    outfile << c640;
    outfile << c641;
    outfile << c642;
    outfile << c643;
    outfile << c644;
    outfile << c645;
    outfile << c646;
    outfile << c647;
    outfile << c648;
    outfile << c649;
    outfile << c650;
    outfile << c651;
    outfile << c652;
    outfile << c653;
    outfile << c654;
    outfile << c655;
    outfile << c656;
    outfile << c657;
    outfile << c658;
    outfile << c659;
    outfile << c660;
    outfile << c661;
    outfile << c662;
    outfile << c663;
    outfile << c664;
    outfile << c665;
    outfile << c666;
    outfile << c667;
    outfile << c668;
    outfile << c669;
    outfile << c670;
    outfile << c671;
    outfile << c672;
    outfile << c673;
    outfile << c674;
    outfile << c675;
    outfile << c676;
    outfile << c677;
    outfile << c678;
    outfile << c679;
    outfile << c680;
    outfile << c681;
    outfile << c682;
    outfile << c683;
    outfile << c684;
    outfile << c685;
    outfile << c686;
    outfile << c687;
    outfile << c688;
    outfile << c689;
    outfile << c690;
    outfile << c691;
    outfile << c692;
    outfile << c693;
    outfile << c694;
    outfile << c695;
    outfile << c696;
    outfile << c697;
    outfile << c698;
    outfile << c699;
    outfile << c700;
    outfile << c701;
    outfile << c702;
    outfile << c703;
    outfile << c704;
    outfile << c705;
    outfile << c706;
    outfile << c707;
    outfile << c708;
    outfile << c709;
    outfile << c710;
    outfile << c711;
    outfile << c712;
    outfile << c713;
    outfile << c714;
    outfile << c715;
    outfile << c716;
    outfile << c717;
    outfile << c718;
    outfile << c719;
    outfile << c720;
    outfile << c721;
    outfile << c722;
    outfile << c723;
    outfile << c724;
    outfile << c725;
    outfile << c726;
    outfile << c727;
    outfile << c728;
    outfile << c729;
    outfile << c730;
    outfile << c731;
    outfile << c732;
    outfile << c733;
    outfile << c734;
    outfile << c735;
    outfile << c736;
    outfile << c737;
    outfile << c738;
    outfile << c739;
    outfile << c740;
    outfile << c741;
    outfile << c742;
    outfile << c743;
    outfile << c744;
    outfile << c745;
    outfile << c746;
    outfile << c747;
    outfile << c748;
    outfile << c749;
    outfile << c750;
    outfile << c751;
    outfile << c752;
    outfile << c753;
    outfile << c754;
    outfile << c755;
    outfile << c756;
    outfile << c757;
    outfile << c758;
    outfile << c759;
    outfile << c760;
    outfile << c761;
    outfile << c762;
    outfile << c763;
    outfile << c764;
    outfile << c765;
    outfile << c766;
    outfile << c767;
    outfile << c768;
    outfile << c769;
    outfile << c770;
    outfile << c771;
    outfile << c772;
    outfile << c773;
    outfile << c774;
    outfile << c775;
    outfile << c776;
    outfile << c777;
    outfile << c778;
    outfile << c779;
    outfile << c780;
    outfile << c781;
    outfile << c782;
    outfile << c783;
    outfile << c784;
    outfile << c785;
    outfile << c786;
    outfile << c787;
    outfile << c788;
    outfile << c789;
    outfile << c790;
    outfile << c791;
    outfile << c792;
    outfile << c793;
    outfile << c794;
    outfile << c795;
    outfile << c796;
    outfile << c797;
    outfile << c798;
    outfile << c799;
    outfile << c800;
    outfile << c801;
    outfile << c802;
    outfile << c803;
    outfile << c804;
    outfile << c805;
    outfile << c806;
    outfile << c807;
    outfile << c808;
    outfile << c809;
    outfile << c810;
    outfile << c811;
    outfile << c812;
    outfile << c813;
    outfile << c814;
    outfile << c815;
    outfile << c816;
    outfile << c817;
    outfile << c818;
    outfile << c819;
    outfile << c820;
    outfile << c821;
    outfile << c822;
    outfile << c823;
    outfile << c824;
    outfile << c825;
    outfile << c826;
    outfile << c827;
    outfile << c828;
    outfile << c829;
    outfile << c830;
    outfile << c831;
    outfile << c832;
    outfile << c833;
    outfile << c834;
    outfile << c835;
    outfile << c836;
    outfile << c837;
    outfile << c838;
    outfile << c839;
    outfile << c840;
    outfile << c841;
    outfile << c842;
    outfile << c843;
    outfile << c844;
    outfile << c845;
    outfile << c846;
    outfile << c847;
    outfile << c848;
    outfile << c849;
    outfile << c850;
    outfile << c851;
    outfile << c852;
    outfile << c853;
    outfile << c854;
    outfile << c855;
    outfile << c856;
    outfile << c857;
    outfile << c858;
    outfile << c859;
    outfile << c860;
    outfile << c861;
    outfile << c862;
    outfile << c863;
    outfile << c864;
    outfile << c865;
    outfile << c866;
    outfile << c867;
    outfile << c868;
    outfile << c869;
    outfile << c870;
    outfile << c871;
    outfile << c872;
    outfile << c873;
    outfile << c874;
    outfile << c875;
    outfile << c876;
    outfile << c877;
    outfile << c878;
    outfile << c879;
    outfile << c880;
    outfile << c881;
    outfile << c882;
    outfile << c883;
    outfile << c884;
    outfile << c885;
    outfile << c886;
    outfile << c887;
    outfile << c888;
    outfile << c889;
    outfile << c890;
    outfile << c891;
    outfile << c892;
    outfile << c893;
    outfile << c894;
    outfile << c895;
    outfile << c896;
    outfile << c897;
    outfile << c898;
    outfile << c899;
    outfile << c900;
    outfile.close();

}

void prepareWriteBitsContent(){
    string line;
    string firstline;
    string str1,str2,str3,str4,str5,str6,str7,str8,str9,str10;
    string str11,str12,str13,str14,str15;
    //ifstream myfile ("C:/Users/Boopathy/OneDrive/Thesis/BITFILE/BitsToWrite1.txt");
    ifstream myfile ("C:/Users/Boopathy/OneDrive/Codec2_Thesis/hts2a_op/encoded_hts2a_jan16.txt");


    if (myfile.is_open())
    {
        int i = 1;
        cout << "hello" << endl;
        while ( getline (myfile,line) )
        {

            cout << line << '\n';

            if(i == 1){
                str1 = line;
            }
            if(i == 2){
                str2 = line;
            }
            if(i == 3){
                str3 = line;
            }
            if(i == 4){
                str4 = line;
            }
            if(i == 5){
                str5 = line;
            }
            if(i == 6){
                str6 = line;
            }
            if(i == 7){
                str7 = line;
            }
            if(i == 8){
                str8 = line;
            }
            if(i == 9){
                str9 = line;
            }
            if(i == 10){
                str10 = line;
            }
            if(i == 11){
                str11 = line;
            }
            if(i == 12){
                str12 = line;
            }
            if(i == 13){
                str13 = line;
            }
            if(i == 14){
                str14 = line;
            }
            if(i == 15){
                str15 = line;
            }

            i++;
        }


        myfile.close();
    }

    cout << endl;
    //cout << "firstline ::" << line << endl;
    int count = 1;
    for(int i =0 ; i < str1.length(); i +=2) {
        cout << "unsigned char c" << count++ << " = 0x" << str1.substr(i,2) << ";" << endl;
    }
    for(int i =0 ; i < str2.length(); i +=2) {
        cout << "unsigned char c" << count++ << " = 0x" << str2.substr(i,2) << ";" << endl;
    }
    for(int i =0 ; i < str3.length(); i +=2) {
        cout << "unsigned char c" << count++ << " = 0x" << str3.substr(i,2) << ";" << endl;
    }
    for(int i =0 ; i < str4.length(); i +=2) {
        cout << "unsigned char c" << count++ << " = 0x" << str4.substr(i,2) << ";" << endl;
    }
    for(int i =0 ; i < str5.length(); i +=2) {
        cout << "unsigned char c" << count++ << " = 0x" << str5.substr(i,2) << ";" << endl;
    }

    for(int i =0 ; i < str6.length(); i +=2) {
        cout << "unsigned char c" << count++ << " = 0x" << str6.substr(i,2) << ";" << endl;
    }
    for(int i =0 ; i < str7.length(); i +=2) {
        cout << "unsigned char c" << count++ << " = 0x" << str7.substr(i,2) << ";" << endl;
    }
    for(int i =0 ; i < str8.length(); i +=2) {
        cout << "unsigned char c" << count++ << " = 0x" << str8.substr(i,2) << ";" << endl;
    }
    for(int i =0 ; i < str9.length(); i +=2) {
        cout << "unsigned char c" << count++ << " = 0x" << str9.substr(i,2) << ";" << endl;
    }
    for(int i =0 ; i < str10.length(); i +=2) {
        cout << "unsigned char c" << count++ << " = 0x" << str10.substr(i,2) << ";" << endl;
    }

    for(int i =0 ; i < str11.length(); i +=2) {
        cout << "unsigned char c" << count++ << " = 0x" << str11.substr(i,2) << ";" << endl;
    }
    for(int i =0 ; i < str12.length(); i +=2) {
        cout << "unsigned char c" << count++ << " = 0x" << str12.substr(i,2) << ";" << endl;
    }
    for(int i =0 ; i < str13.length(); i +=2) {
        cout << "unsigned char c" << count++ << " = 0x" << str13.substr(i,2) << ";" << endl;
    }
    for(int i =0 ; i < str14.length(); i +=2) {
        cout << "unsigned char c" << count++ << " = 0x" << str14.substr(i,2) << ";" << endl;
    }
    for(int i =0 ; i < str15.length(); i +=2) {
        cout << "unsigned char c" << count++ << " = 0x" << str15.substr(i,2) << ";" << endl;
    }

}


void prepareWriteStatements(){


    for(int i =1; i <=900; i++){
        cout << "outfile << c" << i << ";" << endl;
    }

}



void calculateSine(){

    double num =21.6474;//computeDft1.22717;//489.609863281;//3204.4367;
    double pi = 3.141592653589793;
    double pi2 = 2*pi;

    float mod = fmod(num,pi2);
    cout << "mod = " << mod << endl;

    double num1 = mod;
    double x = num1  ;//0.012193338;//6.2953;//3204.436767578;
    double t,t1;
    t = x;
    double sum = x;
    double sum1 = 1;
    t1 = 1;

    double rec1,rec2;
    /* Loop to calculate the value of Sine */
    for(int i=1;i<=10;i++)
    {
        t=(t*(-1)*x*x)/(2*i*(2*i+1));
        sum=sum+t;
        t1=(t1*(-1)*x*x)/(2*i*(2*i-1));
        sum1=sum1+t1;

        rec1 = 1/(double)(2*i*(2*i+1));
        rec2 = 1/(double)(2*i*(2*i-1));
       cout << i << ":: rec1 :: rec2 :: " << rec1 << " :: " << rec2 << endl;
      //  cout << "t :: " << t << endl;

       // if(i == 1){
            cout << "sum :" << sum << endl;
       // }

    }

    cout<<" The value of Sin("<<x<<") = "<<sum << endl;
    cout<<" The value of Cos("<<x<<") = "<<sum1 << endl;
}


void fpmodCalc(){
    double num1 = 3204.6474;//3204.4367;
    double pi = 3.141592653589793;
    double pi2 = 2*pi;
    double num2 = pi2;

    double mod = num1;
    double count = 0;

    while( mod >= num2){
        mod = mod - num2;
        count++;
    }

    cout << endl;
    cout << "modulus of " << num1 << "by" << num2 << "is  :: " << mod << endl;
    cout << "count " << count;

}


void vector_decimaltoBinary_48(float *codes0,int n){
    // string ret_string = "";
    for(int i =0; i< n;i++){
        double codes_loc;
        if(codes0[i] < 0){
            codes_loc = codes0[i] - (2*codes0[i]);
        }else{
            codes_loc = codes0[i];
        }

        //cout << codes0[i] << endl;

        string codes_bin = decimalToBinary(codes_loc,32);
        int len = codes_bin.length();
        // cb0 = 32'b00000000000000101011010111000010,

        //cout  << "nlp_fir" << i << "  = 80'b" ;
        cout << "w["<<i<<"]" << "  =  48'b";
        //ret_string.append(to_string(i) + " : ");
        if(codes0[i] < 0){
            cout<<"1";
            for(int i =1;i < 48-len;i++) {
                cout << "0" ;
            }
            cout << codes_bin << ";" <<endl;
        }else{
            for(int i =1;i < 49-len;i++) {
                cout << "0" ;
            }
            cout << codes_bin << ";" <<endl;
        }
    }

}



void readBitFile(){
    ifstream myfile ("C:/Users/Boopathy/OneDrive/Codec2_Thesis/outputcomparecodec2/hts1a_c2.bit" , ios::binary | ios::in);
    char c;
    while (myfile.get(c)) {
      for  (int i = 7; i >= 0; i--)
            cout << ((c >> i) & 1);
    }
}


void readVerilogRawFile(){
    string line;
    short value;
    char buf[sizeof(short)];
    ifstream myfile ("C:/Users/Boopathy/OneDrive/Codec2_Thesis/matlab_data/hts2a_jan16_verilog.raw", ios::binary);

    //C:\Users\Boopathy\OneDrive\Codec2_Thesis\matlab_data
    if (myfile.is_open())
    {
        int i = 1;
       // unsigned char ch;
        cout << "hello" << endl;
        while ( myfile.read(buf, sizeof(buf)))
        {
            memcpy(&value, buf, sizeof(value));
          //  cout << line << '\n';
            cout << value << ",";

            i++;
        }

        cout << endl;
        cout << "i is " << i;
        myfile.close();
    }
}

void compareTwoBitFiles(){
    cout << "compareTwoBitFiles ::::::::::::" << endl;
    ifstream verilog11;
    verilog11.open("C:/Users/Boopathy/OneDrive/Codec2_Thesis/outputcomparecodec2/verilog1_bit.txt");
    ifstream sw      ("C:/Users/Boopathy/OneDrive/Codec2_Thesis/outputcomparecodec2/1a_bit.txt");

    string line, str1, str2, str3, str4, str5;
    if (verilog11.is_open())
    {
        int i = 1;
        cout << "hello------------" << endl;
        while ( getline (verilog11,line) )
        {
            cout << line << '\n';

            if(i == 1){
                str1 = line;
            }
            if(i == 2){
                str2 = line;
            }
            if(i == 3){
                str3 = line;
            }
            if(i == 4){
                str4 = line;
            }
            if(i == 5){
                str5 = line;
            }

            i++;
        }

        verilog11.close();
    }

    string line1, str_1, str_2, str_3, str_4, str_5;
    if (sw.is_open())
    {
        int i = 1;
        cout << "hello1" << endl;
        while ( getline (sw,line) )
        {

            cout << line1 << '\n';

            if(i == 1){
                str_1 = line1;
            }
            if(i == 2){
                str_2 = line1;
            }
            if(i == 3){
                str_3 = line1;
            }
            if(i == 4){
                str_4 = line1;
            }
            if(i == 5){
                str_5 = line1;
            }

            i++;
        }


        sw.close();
    }

    cout << "compareTwoBitFiles ::::::::::::   end :::::::::::::" << endl;

}



void compare2strings(){
    string str1	=	"111110111000000110110001110101110011011111001000";
    string str2	=	"111100000100000100110001010101101011011111001000";
    string str3	=	"111101000100000111110001110100101011011101001000";
    string str4	=	"110100110100000101010101010100110011011111011000";
    string str5	=	"111100011000000111011001110101110110101111001000";
    string str6	=	"110111010100000111011101110101110111011111001000";
    string str7	=	"111010000100000010010101110101110111011111001000";
    string str8	=	"111101111000000001011001100101110111001111001000";
    string str9	=	"111110000100000010011001110101101011011101001000";
    string str10	=	"110101011000000111011001110100110111011101011000";
    string str11	=	"111000101000000101011001110100110011001101011100";
    string str12	=	"110000001100001101010001010101110011011101111000";
    string str13	=	"110001101101010111010101110111010011010111110100";
    string str14	=	"110111101101010110011001110110010111000011110100";
    string str15	=	"110000001101000111010101010111010111000011011100";
    string str16	=	"111011001101010111011101110111010111000011011100";
    string str17	=	"110001111100110010010000110111010101110010010000";
    string str18	=	"111010101100110010110000100101010001010010010000";
    string str19	=	"111111101100110011110000100101010001010010010000";
    string str20	=	"111111101100100010110001100111010101000010100100";
    string str21	=	"110100010011000101010001110111011111000101011100";
    string str22	=	"110110001111011101101001010111010111000111011100";
    string str23	=	"110111011110101101101101000101010011010101011100";
    string str24	=	"110101101111010100101111000100110011010101111100";
    string str25	=	"111011001111000101010011001100110011010101100100";
    string str26	=	"110101101101010111010111001101110110100101100100";
    string str27	=	"111010101101100010010111001010110110100101110100";
    string str28	=	"110000101101100011110110101010101011010111011100";
    string str29	=	"110000000100100011110010101101101011000111001100";
    string str30	=	"110100100100100010101101000100110101000111011100";
    string str31	=	"111001000101100111101111000100110011000111011100";
    string str32	=	"111010001101100010101111011100110111000101011100";
    string str33	=	"111010101100100001001001011101110001010010001100";
    string str34	=	"110110101100110001000001111010110111000111001100";
    string str35	=	"110000000100010001000001111010101011000111110100";
    string str36	=	"110110101100110001000000001010110111000101011100";
    string str37	=	"110000001101100001000101011010110111000011010100";
    string str38	=	"110111011101010110001101001100010011000011110100";
    string str39	=	"111100101101000111011001000100010111000011010100";
    string str40	=	"110101101101000111010101010101010101000011100100";
    string str41	=	"111100011101110101110001000101010011000011100100";
    string str42	=	"111011011001110110000101110101010111000011111100";
    string str43	=	"110010001000010010000101100111010001001101011100";
    string str44	=	"111000111000010110011101110101101011011101111100";
    string str45	=	"110000100010111100110001001100101110101101110100";
    string str46	=	"111001101010111111101101001100101010101101001100";
    string str47	=	"110101111110101110101011001100101010101101011100";
    string str48	=	"111111111001011011110001000100010011010111011100";
    string str49	=	"111011101101001100110001000100010001000010100100";
    string str50	=	"110011001110101101110111000100010011000011100100";
    string str51	=	"111100011110101100011101110100010001000010100100";
    string str52	=	"111100011111010100001001110100010001010010110100";
    string str53	=	"111100011101010111001101101100110001010011100100";
    string str54	=	"110111011001100110001101011100110001000011100100";
    string str55	=	"111110111101110111001101110101110011000101111100";
    string str56	=	"110011011001110100010101010100110111000111100100";
    string str57	=	"110010111000000000011101010101110011000101111100";
    string str58	=	"110010000100000100011001110100110111011101011000";
    string str59	=	"111100010010101011111111011100101110111101100100";
    string str60	=	"110011101011011111111111011100110011011011010100";
    string str61	=	"111110001001101101111111000100101110111111011100";
    string str62	=	"110100010100001010010101111100101010101111011100";
    string str63	=	"111000111000000111011101010100110111011111011100";
    string str64	=	"110110111000000111011101110101110111001111011100";
    string str65	=	"111000101100110011010001110111110111000101110100";
    string str66	=	"110111010001110110010101110110110111000101011000";
    string str67	=	"111001001101010111110101010111110111011111001000";
    string str68	=	"111001010101110010110001110110110101000011010100";
    string str69	=	"110100010100110011000101100010010101010011111100";
    string str70	=	"110011011100010011000000000010011101000111011000";
    string str71	=	"111011100100000000000001110110010001001101111100";
    string str72	=	"111111101000010000000001010101110111011101111100";
    string str73	=	"111100100001100010010001000100010001000010000100";
    string str74	=	"111011101101100011110011011100110111000111010100";
    string str75	=	"111100101100100011010111011101110111010111010100";
    string str76	=	"110110101100110001000011001010101011010111011100";
    string str77	=	"110010111100010000011001011010101001000010001100";
    string str78	=	"111111010100000001000000001100101001010011011100";
    string str79	=	"111000001000000001000000000100101001000111011100";
    string str80	=	"110001000100000001000000000000101001000101111100";
    string str81	=	"110000011100000000000100010110110001000111111000";
    string str82	=	"110101000100010011001001100110010101000101101100";
    string str83	=	"111000111000000001001001100101110111001111011000";
    string str84	=	"111100100010101010110001001101101010101111010100";
    string str85	=	"111110100011011101111011011100101111001011001100";
    string str86	=	"110111100101001100110011000101010011010111001100";
    string str87	=	"110000110101111101110101010101110011000111010100";
    string str88	=	"110011011001001101010001100111011101000011110100";
    string str89	=	"110000001110101011010001100110010101010011001100";
    string str90	=	"110011001111001100101001110110010001000101001100";
    string str91	=	"110011000111001011110101100010010001010111001100";
    string str92	=	"110000101111011011110101100010010001010010001100";
    string str93	=	"111111101111011011110101100010010001010011011100";
    string str94	=	"110000101111001011110001100010011101010111011100";
    string str95	=	"110000000111011010110001100010011101010011111100";
    string str96	=	"111010011111011100101001010100110111011111010100";
    string str97	=	"110101101110111111111111001011110111001011001100";
    string str98	=	"110110011011001111111111011011110111011011001100";
    string str99	=	"111000100011001111111110101011111011011011001100";
    string str100	=	"110101001000010000110001111100101111011011010100";
    string str101	=	"110100111000000000111001010111010010101101100100";
    string str102	=	"111101001011001111101001110111010101000111100100";
    string str103	=	"110101001111011100101001110101010011010101110100";
    string str104	=	"111010010100011101110001001100110110101101011100";
    string str105	=	"111101010100001100110101011100101010101101011100";
    string str106	=	"111011001000001100101011001100101010111111110100";
    string str107	=	"111000011100110000111011001101101010101101010100";
    string str108	=	"111000101111001101101001110100010011000101011100";
    string str109	=	"110001011001110010011000010010110011000111010100";
    string str110	=	"111100101101110010001000010000110011000101010100";
    string str111	=	"111010000101110010001100010000000011001101010100";
    string str112	=	"110000000101100011001100000000110111000101010100";
    string str113	=	"111010000101110010001100000000000011011101110100";
    string str114	=	"110001100101110010001100010000000011011101110100";
    string str115	=	"110001100101110010001000010001101011010101110100";
    string str116	=	"110101000101110110011000110001010011000101110100";
    string str117	=	"111010000101110110010100100010101011010101100100";
    string str118	=	"110111001001110110101001101010110111011111110100";
    string str119	=	"110010101101011110111011011011111011011111110100";
    string str120	=	"110011011011001111111111001100110111011111110100";
    string str121	=	"110110100111011111111111001010110011011111110100";
    string str122	=	"110010101111011111111111001011111011011111010100";
    string str123	=	"111010011011001111111111011100111011001101110100";
    string str124	=	"111100100111001111111111001011110010111101100100";
    string str125	=	"111110111101101111111011001100110010111101100100";
    string str126	=	"111110010100011100110101011011110011010110100100";
    string str127	=	"111110111000000100010001010100101011001101101100";
    string str128	=	"110001110100001100011101110101110111011101011000";
    string str129	=	"111110010100000111011101110101110111011111001000";
    string str130	=	"111010011000000110011101110101110111001101011000";
    string str131	=	"111011000100000010001001110101101011011101111000";
    string str132	=	"110011110100000111011101110101110111011111001000";
    string str133	=	"111100011000000110011001110101110111011101011000";
    string str134	=	"111110000100000111011101110101110111011101011000";
    string str135	=	"111100111000000110011001110101110111011111011000";
    string str136	=	"110000100100000101011101010100110110101111101100";
    string str137	=	"110010110100000110011001010101110111011111011000";
    string str138	=	"111110100100000111011101110100110111011111011000";
    string str139	=	"110111111000000110011001100101110111011111011000";
    string str140	=	"111100100100000010011101010100110011011101011100";
    string str141	=	"110011110100000101011101110101110111001101011000";
    string str142	=	"111000001000000111001001110101110111011111001000";
    string str143	=	"110001000100000111011001110101110011011101011000";
    string str144	=	"111010111000000111011001100101110111011101011000";
    string str145	=	"110101011100000101011101110101110111001101001000";
    string str146	=	"111101000100000111011101010101101011011101001000";
    string str147	=	"111001011100000111011001010100110111001101001000";
    string str148	=	"111010011000000011001001010101110111001111001000";
    string str149	=	"110111010100000111010101100100110111011111001000";
    string str150	=	"110100000100000111011101110100110111001111001000";


    string str_1	=	"111110111000000110110001110101110011011111001000";
    string str_2	=	"111100000100000100110001010101111111011111001000";
    string str_3	=	"111101000100000111110001110100111111011101001000";
    string str_4	=	"110100110100000101010101010100110011011111011000";
    string str_5	=	"110000111000000111011001110101110111111111001000";
    string str_6	=	"111100011000000110011101110101110111011111001000";
    string str_7	=	"110000000100000010010101110101110111011111001000";
    string str_8	=	"110001100100000001011001100101110111001111001000";
    string str_9	=	"111100011100000011011001110101111111011101001000";
    string str_10	=	"110010110100000111011001110100110111011101011000";
    string str_11	=	"100110011000000100011001010100110011001101011000";
    string str_12	=	"111011100100001100010101110101110011011101111100";
    string str_13	=	"111011000001010111010101110111010011010111110100";
    string str_14	=	"110111101101010110011001110110010111000011100100";
    string str_15	=	"111100001101000111010101010111010111000011011100";
    string str_16	=	"111010101101010111011101110111010111000011011100";
    string str_17	=	"111000111100110010010000110111010101110010010000";
    string str_18	=	"111011001100110011110000100101010101010010010000";
    string str_19	=	"111111101100110011110000100101010101010010010000";
    string str_20	=	"111111101100100010110001100111010101000010100100";
    string str_21	=	"110100010011000101010001110111011011000101011100";
    string str_22	=	"110011001111011101111101010111010111000111011100";
    string str_23	=	"111001101111111101111001000101010011010101011100";
    string str_24	=	"110101101111010100111011000100110011010101111100";
    string str_25	=	"111011001111000101010011001100110011010101100100";
    string str_26	=	"111111101101110111010111001101110111110101100100";
    string str_27	=	"110011101101100010010111001111110111110101110100";
    string str_28	=	"110000101101100011110111111111111111010111011100";
    string str_29	=	"110000000100100011101011111101111111000111001100";
    string str_30	=	"110100100100100010111001000100110101000111011100";
    string str_31	=	"111001000101100111111011000100110011000111011100";
    string str_32	=	"110110001101100010111011011100110111000101011100";
    string str_33	=	"110110101100100001001001011101110001010001001100";
    string str_34	=	"110110101100110000000101111111110111000111001100";
    string str_35	=	"110000000100010000000001111111111111000111110100";
    string str_36	=	"110110101100110000000001101111110111000101011100";
    string str_37	=	"110000001101100001000101011111110111000011010100";
    string str_38	=	"110110001101010110001101001100010011000011110100";
    string str_39	=	"110011101101000111011001000100010111000011010100";
    string str_40	=	"111010001101000111010101010101010101000001100100";
    string str_41	=	"111100011101110101110001000101010011000011100100";
    string str_42	=	"111011011001110110000101110101010101000011111100";
    string str_43	=	"111110001000010010000101100111010001001101011100";
    string str_44	=	"111000101000000110011101110100111111011101111100";
    string str_45	=	"010100110011101010101001001100111011111101110100";
    string str_46	=	"100111001111101000111001001100111111111101001100";
    string str_47	=	"001110001111011101110001010100010011010111010100";
    string str_48	=	"010101110101011110110001000100010011000011010100";
    string str_49	=	"110111100001001100110001000100010001000010110100";
    string str_50	=	"110101001111111101110111000100010011000011100100";
    string str_51	=	"110011000111111100011101110100010001000010100100";
    string str_52	=	"111100011111010100001001110100010001010000110100";
    string str_53	=	"111101111101010111001101101100110001010011100100";
    string str_54	=	"110111011001100110001101011100110001000010100100";
    string str_55	=	"111110111101110111001101110101110011000101111100";
    string str_56	=	"100011011001110100010101010100110111000111100100";
    string str_57	=	"110110010100000100011101010101110011000101111100";
    string str_58	=	"110010100100000100011001110100110111011101011000";
    string str_59	=	"010101010011111110100011011100111011101101100100";
    string str_60	=	"011100011111011000100011011100101010111011010100";
    string str_61	=	"000000010101101011100011000100111011101111011100";
    string str_62	=	"100100111000001111010101111100111111111111011100";
    string str_63	=	"000100000100000111011101010100110111011111011100";
    string str_64	=	"110000111000000111011101110101110111001111011100";
    string str_65	=	"111000101100110011010001110111110111000101110100";
    string str_66	=	"111011010001110010010101110110010111000011100100";
    string str_67	=	"111011101101010110110001010110010011000011011100";
    string str_68	=	"111110111101110010110001110110110101000011010100";
    string str_69	=	"110100010100110011000101100010010101010011111100";
    string str_70	=	"110000010100010011000001110010011101000111111000";
    string str_71	=	"111110100100000000001101110110010001000101111100";
    string str_72	=	"110011100100010000001001010101110111011101111100";
    string str_73	=	"011011010001100010010001000100010001000001110100";
    string str_74	=	"110001101101100011110011011100110111000111010100";
    string str_75	=	"111010001100100011010111011101110111010111010100";
    string str_76	=	"111100011100110000011011001111111111010111011100";
    string str_77	=	"111110111100010000011001011111111101000001011100";
    string str_78	=	"110101010100000001000000011100111101010011011100";
    string str_79	=	"111101111100000001000000010100111101000111011100";
    string str_80	=	"111101111100000001000000000100111101000101111100";
    string str_81	=	"110011000100000011000100010110110001000011111000";
    string str_82	=	"111111000100000011001001100110010101000101101100";
    string str_83	=	"111000111000000001001001100101110111001111011000";
    string str_84	=	"100000010011111111101001001101111111111111010100";
    string str_85	=	"100010100011011011100111011100111010101011001100";
    string str_86	=	"001110010101001100101011000101010011010111001100";
    string str_87	=	"101010110101111101110101010101110011000111010100";
    string str_88	=	"110011011001001101010001100111011101000011110100";
    string str_89	=	"110000001111111110010001100110010101010011001100";
    string str_90	=	"110000001110101010111101110110010001000101001100";
    string str_91	=	"110110101110101110110101100010010001010111011100";
    string str_92	=	"111010001110111110110101100010010001010001011100";
    string str_93	=	"110000101110111110110101100010010101010011011100";
    string str_94	=	"110011000110101110110001100010011101010111011100";
    string str_95	=	"111111000111011111110001100010011101010011111100";
    string str_96	=	"101001011111011010111101010100110111011111010100";
    string str_97	=	"000011101111101000100011001110101110101011001100";
    string str_98	=	"001010011010101000100011011110101110111011001100";
    string str_99	=	"001100110110111000100011111110100110111011001100";
    string str_100	=	"001110011000011000101001111100111010111011010100";
    string str_101	=	"011110000100001000100101010111010011111101100100";
    string str_102	=	"111010110111001000111101110111010101000111100100";
    string str_103	=	"111011100011011010111101110101010011010101110100";
    string str_104	=	"000100010100011101101001001100110111111101011100";
    string str_105	=	"111011100100001100110101011100111111111101011100";
    string str_106	=	"000101100100001100111111001100111111101111110100";
    string str_107	=	"001110101100111000100111001101111111111101010100";
    string str_108	=	"011100001111001011111101110100010011000101011100";
    string str_109	=	"111110110101110010011000010010110011000111010100";
    string str_110	=	"111111000101110010001000000000110011000111010100";
    string str_111	=	"110101000101110011001100000000110011000111010100";
    string str_112	=	"111100000101100011001100000000110011000111010100";
    string str_113	=	"111010000101110010001100000000110011010101110100";
    string str_114	=	"111010000101110010000100000000110011010101110100";
    string str_115	=	"110001100101110010001000010000111111010101110100";
    string str_116	=	"111001000101110110011000110001010011000101110100";
    string str_117	=	"110000000101110110010100100010111111010101100100";
    string str_118	=	"101100001101110110111101101111101110111111110100";
    string str_119	=	"000011011001011001100111011110100110111111110100";
    string str_120	=	"000101110111001000100011001010101110111111110100";
    string str_121	=	"000101111110111000100011001111101010111111110100";
    string str_122	=	"000101011010111000100011001110100110111111010100";
    string str_123	=	"000110110110101000100011011010100110101101110100";
    string str_124	=	"001101000110101000100011001110101011101101100100";
    string str_125	=	"001101010101101000100111001010101011101101100100";
    string str_126	=	"001000111000011010110101011110101011010110100100";
    string str_127	=	"001000100100000100010001010100111111001101101100";
    string str_128	=	"111000100100001100011101110101110111011101011000";
    string str_129	=	"111110000100000111011101110101110111011111001000";
    string str_130	=	"110111010100000110011101110101110111001101011000";
    string str_131	=	"111010011100000010001001110101111111011101111000";
    string str_132	=	"111110000100000111011101110101110111011111001000";
    string str_133	=	"111110000100000110011001110101110111011101011000";
    string str_134	=	"111011010100000111011101110101110111011101011000";
    string str_135	=	"110110101100000110011001110101110111011111011000";
    string str_136	=	"100000100100000101011101010100110111111111101100";
    string str_137	=	"111110110100000110011001010101110111011111011000";
    string str_138	=	"110010100100000111011101110100110111011111011000";
    string str_139	=	"110000011000000110011001100101110111011101011000";
    string str_140	=	"111001100100000010011101010100110011011101011100";
    string str_141	=	"111011010100000101011101110101110111001101011000";
    string str_142	=	"111010000100000110001001110101110111011111001000";
    string str_143	=	"110100110100000111011001110101110011011101011000";
    string str_144	=	"111010011100000111011001100101110111011101011000";
    string str_145	=	"111010011100000101011101110101110111001101001000";
    string str_146	=	"111110000100000111011101010101111111011101001000";
    string str_147	=	"111111000100000111011001010100110111001101001000";
    string str_148	=	"111010000100000011001001010101110111001111001000";
    string str_149	=	"111110000100000111010101100100110111011111001000";
    string str_150	=	"110100000100000111011101110100110111001111001000";


    int   	count1	=	0	;
    int   	count2	=	0	;
    int   	count3	=	0	;
    int   	count4	=	0	;
    int   	count5	=	0	;
    int   	count6	=	0	;
    int   	count7	=	0	;
    int   	count8	=	0	;
    int   	count9	=	0	;
    int   	count10	=	0	;
    int   	count11	=	0	;
    int   	count12	=	0	;
    int   	count13	=	0	;
    int   	count14	=	0	;
    int   	count15	=	0	;
    int   	count16	=	0	;
    int   	count17	=	0	;
    int   	count18	=	0	;
    int   	count19	=	0	;
    int   	count20	=	0	;
    int   	count21	=	0	;
    int   	count22	=	0	;
    int   	count23	=	0	;
    int   	count24	=	0	;
    int   	count25	=	0	;
    int   	count26	=	0	;
    int   	count27	=	0	;
    int   	count28	=	0	;
    int   	count29	=	0	;
    int   	count30	=	0	;
    int   	count31	=	0	;
    int   	count32	=	0	;
    int   	count33	=	0	;
    int   	count34	=	0	;
    int   	count35	=	0	;
    int   	count36	=	0	;
    int   	count37	=	0	;
    int   	count38	=	0	;
    int   	count39	=	0	;
    int   	count40	=	0	;
    int   	count41	=	0	;
    int   	count42	=	0	;
    int   	count43	=	0	;
    int   	count44	=	0	;
    int   	count45	=	0	;
    int   	count46	=	0	;
    int   	count47	=	0	;
    int   	count48	=	0	;
    int   	count49	=	0	;
    int   	count50	=	0	;
    int   	count51	=	0	;
    int   	count52	=	0	;
    int   	count53	=	0	;
    int   	count54	=	0	;
    int   	count55	=	0	;
    int   	count56	=	0	;
    int   	count57	=	0	;
    int   	count58	=	0	;
    int   	count59	=	0	;
    int   	count60	=	0	;
    int   	count61	=	0	;
    int   	count62	=	0	;
    int   	count63	=	0	;
    int   	count64	=	0	;
    int   	count65	=	0	;
    int   	count66	=	0	;
    int   	count67	=	0	;
    int   	count68	=	0	;
    int   	count69	=	0	;
    int   	count70	=	0	;
    int   	count71	=	0	;
    int   	count72	=	0	;
    int   	count73	=	0	;
    int   	count74	=	0	;
    int   	count75	=	0	;
    int   	count76	=	0	;
    int   	count77	=	0	;
    int   	count78	=	0	;
    int   	count79	=	0	;
    int   	count80	=	0	;
    int   	count81	=	0	;
    int   	count82	=	0	;
    int   	count83	=	0	;
    int   	count84	=	0	;
    int   	count85	=	0	;
    int   	count86	=	0	;
    int   	count87	=	0	;
    int   	count88	=	0	;
    int   	count89	=	0	;
    int   	count90	=	0	;
    int   	count91	=	0	;
    int   	count92	=	0	;
    int   	count93	=	0	;
    int   	count94	=	0	;
    int   	count95	=	0	;
    int   	count96	=	0	;
    int   	count97	=	0	;
    int   	count98	=	0	;
    int   	count99	=	0	;
    int   	count100	=	0	;
    int   	count101	=	0	;
    int   	count102	=	0	;
    int   	count103	=	0	;
    int   	count104	=	0	;
    int   	count105	=	0	;
    int   	count106	=	0	;
    int   	count107	=	0	;
    int   	count108	=	0	;
    int   	count109	=	0	;
    int   	count110	=	0	;
    int   	count111	=	0	;
    int   	count112	=	0	;
    int   	count113	=	0	;
    int   	count114	=	0	;
    int   	count115	=	0	;
    int   	count116	=	0	;
    int   	count117	=	0	;
    int   	count118	=	0	;
    int   	count119	=	0	;
    int   	count120	=	0	;
    int   	count121	=	0	;
    int   	count122	=	0	;
    int   	count123	=	0	;
    int   	count124	=	0	;
    int   	count125	=	0	;
    int   	count126	=	0	;
    int   	count127	=	0	;
    int   	count128	=	0	;
    int   	count129	=	0	;
    int   	count130	=	0	;
    int   	count131	=	0	;
    int   	count132	=	0	;
    int   	count133	=	0	;
    int   	count134	=	0	;
    int   	count135	=	0	;
    int   	count136	=	0	;
    int   	count137	=	0	;
    int   	count138	=	0	;
    int   	count139	=	0	;
    int   	count140	=	0	;
    int   	count141	=	0	;
    int   	count142	=	0	;
    int   	count143	=	0	;
    int   	count144	=	0	;
    int   	count145	=	0	;
    int   	count146	=	0	;
    int   	count147	=	0	;
    int   	count148	=	0	;
    int   	count149	=	0	;
    int   	count150	=	0	;


    int sum =0;

  //  int count = 0;
    for(int i = 0; i < 48; i++){
        if(str1[i] != str_1[i]){
            count1++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str2[i] != str_2[i]){
            count2++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str3[i] != str_3[i]){
            count3++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str4[i] != str_4[i]){
            count4++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str5[i] != str_5[i]){
            count5++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str6[i] != str_6[i]){
            count6++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str7[i] != str_7[i]){
            count7++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str8[i] != str_8[i]){
            count8++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str9[i] != str_9[i]){
            count9++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str10[i] != str_10[i]){
            count10++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str11[i] != str_11[i]){
            count11++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str12[i] != str_12[i]){
            count12++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str13[i] != str_13[i]){
            count13++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str14[i] != str_14[i]){
            count14++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str15[i] != str_15[i]){
            count15++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str16[i] != str_16[i]){
            count16++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str17[i] != str_17[i]){
            count17++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str18[i] != str_18[i]){
            count18++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str19[i] != str_19[i]){
            count19++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str20[i] != str_20[i]){
            count20++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str21[i] != str_21[i]){
            count21++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str22[i] != str_22[i]){
            count22++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str23[i] != str_23[i]){
            count23++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str24[i] != str_24[i]){
            count24++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str25[i] != str_25[i]){
            count25++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str26[i] != str_26[i]){
            count26++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str27[i] != str_27[i]){
            count27++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str28[i] != str_28[i]){
            count28++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str29[i] != str_29[i]){
            count29++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str30[i] != str_30[i]){
            count30++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str31[i] != str_31[i]){
            count31++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str32[i] != str_32[i]){
            count32++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str33[i] != str_33[i]){
            count33++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str34[i] != str_34[i]){
            count34++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str35[i] != str_35[i]){
            count35++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str36[i] != str_36[i]){
            count36++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str37[i] != str_37[i]){
            count37++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str38[i] != str_38[i]){
            count38++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str39[i] != str_39[i]){
            count39++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str40[i] != str_40[i]){
            count40++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str41[i] != str_41[i]){
            count41++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str42[i] != str_42[i]){
            count42++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str43[i] != str_43[i]){
            count43++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str44[i] != str_44[i]){
            count44++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str45[i] != str_45[i]){
            count45++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str46[i] != str_46[i]){
            count46++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str47[i] != str_47[i]){
            count47++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str48[i] != str_48[i]){
            count48++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str49[i] != str_49[i]){
            count49++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str50[i] != str_50[i]){
            count50++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str51[i] != str_51[i]){
            count51++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str52[i] != str_52[i]){
            count52++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str53[i] != str_53[i]){
            count53++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str54[i] != str_54[i]){
            count54++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str55[i] != str_55[i]){
            count55++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str56[i] != str_56[i]){
            count56++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str57[i] != str_57[i]){
            count57++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str58[i] != str_58[i]){
            count58++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str59[i] != str_59[i]){
            count59++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str60[i] != str_60[i]){
            count60++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str61[i] != str_61[i]){
            count61++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str62[i] != str_62[i]){
            count62++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str63[i] != str_63[i]){
            count63++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str64[i] != str_64[i]){
            count64++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str65[i] != str_65[i]){
            count65++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str66[i] != str_66[i]){
            count66++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str67[i] != str_67[i]){
            count67++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str68[i] != str_68[i]){
            count68++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str69[i] != str_69[i]){
            count69++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str70[i] != str_70[i]){
            count70++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str71[i] != str_71[i]){
            count71++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str72[i] != str_72[i]){
            count72++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str73[i] != str_73[i]){
            count73++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str74[i] != str_74[i]){
            count74++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str75[i] != str_75[i]){
            count75++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str76[i] != str_76[i]){
            count76++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str77[i] != str_77[i]){
            count77++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str78[i] != str_78[i]){
            count78++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str79[i] != str_79[i]){
            count79++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str80[i] != str_80[i]){
            count80++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str81[i] != str_81[i]){
            count81++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str82[i] != str_82[i]){
            count82++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str83[i] != str_83[i]){
            count83++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str84[i] != str_84[i]){
            count84++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str85[i] != str_85[i]){
            count85++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str86[i] != str_86[i]){
            count86++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str87[i] != str_87[i]){
            count87++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str88[i] != str_88[i]){
            count88++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str89[i] != str_89[i]){
            count89++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str90[i] != str_90[i]){
            count90++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str91[i] != str_91[i]){
            count91++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str92[i] != str_92[i]){
            count92++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str93[i] != str_93[i]){
            count93++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str94[i] != str_94[i]){
            count94++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str95[i] != str_95[i]){
            count95++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str96[i] != str_96[i]){
            count96++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str97[i] != str_97[i]){
            count97++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str98[i] != str_98[i]){
            count98++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str99[i] != str_99[i]){
            count99++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str100[i] != str_100[i]){
            count100++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str101[i] != str_101[i]){
            count101++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str102[i] != str_102[i]){
            count102++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str103[i] != str_103[i]){
            count103++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str104[i] != str_104[i]){
            count104++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str105[i] != str_105[i]){
            count105++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str106[i] != str_106[i]){
            count106++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str107[i] != str_107[i]){
            count107++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str108[i] != str_108[i]){
            count108++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str109[i] != str_109[i]){
            count109++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str110[i] != str_110[i]){
            count110++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str111[i] != str_111[i]){
            count111++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str112[i] != str_112[i]){
            count112++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str113[i] != str_113[i]){
            count113++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str114[i] != str_114[i]){
            count114++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str115[i] != str_115[i]){
            count115++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str116[i] != str_116[i]){
            count116++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str117[i] != str_117[i]){
            count117++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str118[i] != str_118[i]){
            count118++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str119[i] != str_119[i]){
            count119++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str120[i] != str_120[i]){
            count120++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str121[i] != str_121[i]){
            count121++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str122[i] != str_122[i]){
            count122++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str123[i] != str_123[i]){
            count123++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str124[i] != str_124[i]){
            count124++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str125[i] != str_125[i]){
            count125++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str126[i] != str_126[i]){
            count126++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str127[i] != str_127[i]){
            count127++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str128[i] != str_128[i]){
            count128++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str129[i] != str_129[i]){
            count129++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str130[i] != str_130[i]){
            count130++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str131[i] != str_131[i]){
            count131++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str132[i] != str_132[i]){
            count132++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str133[i] != str_133[i]){
            count133++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str134[i] != str_134[i]){
            count134++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str135[i] != str_135[i]){
            count135++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str136[i] != str_136[i]){
            count136++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str137[i] != str_137[i]){
            count137++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str138[i] != str_138[i]){
            count138++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str139[i] != str_139[i]){
            count139++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str140[i] != str_140[i]){
            count140++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str141[i] != str_141[i]){
            count141++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str142[i] != str_142[i]){
            count142++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str143[i] != str_143[i]){
            count143++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str144[i] != str_144[i]){
            count144++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str145[i] != str_145[i]){
            count145++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str146[i] != str_146[i]){
            count146++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str147[i] != str_147[i]){
            count147++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str148[i] != str_148[i]){
            count148++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str149[i] != str_149[i]){
            count149++;
        }
    }

    for(int i = 0; i < 48; i++){
        if(str150[i] != str_150[i]){
            count150++;
        }
    }



    /*for(int i=1; i <= 150; i++){
        cout << "for(int i = 0; i < 48; i++){" << endl;
        cout << "   if(str"<< i<<"[i] != str_"<<i <<"[i]){" << endl;
        cout << "      count" << i << "++;" << endl;
        cout << "   }" << endl;
        cout << "}" << endl;
        cout << endl;
    }*/

    sum = count1	+
          count2	+
          count3	+
          count4	+
          count5	+
          count6	+
          count7	+
          count8	+
          count9	+
          count10	+
          count11	+
          count12	+
          count13	+
          count14	+
          count15	+
          count16	+
          count17	+
          count18	+
          count19	+
          count20	+
          count21	+
          count22	+
          count23	+
          count24	+
          count25	+
          count26	+
          count27	+
          count28	+
          count29	+
          count30	+
          count31	+
          count32	+
          count33	+
          count34	+
          count35	+
          count36	+
          count37	+
          count38	+
          count39	+
          count40	+
          count41	+
          count42	+
          count43	+
          count44	+
          count45	+
          count46	+
          count47	+
          count48	+
          count49	+
          count50	+
          count51	+
          count52	+
          count53	+
          count54	+
          count55	+
          count56	+
          count57	+
          count58	+
          count59	+
          count60	+
          count61	+
          count62	+
          count63	+
          count64	+
          count65	+
          count66	+
          count67	+
          count68	+
          count69	+
          count70	+
          count71	+
          count72	+
          count73	+
          count74	+
          count75	+
          count76	+
          count77	+
          count78	+
          count79	+
          count80	+
          count81	+
          count82	+
          count83	+
          count84	+
          count85	+
          count86	+
          count87	+
          count88	+
          count89	+
          count90	+
          count91	+
          count92	+
          count93	+
          count94	+
          count95	+
          count96	+
          count97	+
          count98	+
          count99	+
          count100	+
          count101	+
          count102	+
          count103	+
          count104	+
          count105	+
          count106	+
          count107	+
          count108	+
          count109	+
          count110	+
          count111	+
          count112	+
          count113	+
          count114	+
          count115	+
          count116	+
          count117	+
          count118	+
          count119	+
          count120	+
          count121	+
          count122	+
          count123	+
          count124	+
          count125	+
          count126	+
          count127	+
          count128	+
          count129	+
          count130	+
          count131	+
          count132	+
          count133	+
          count134	+
          count135	+
          count136	+
          count137	+
          count138	+
          count139	+
          count140	+
          count141	+
          count142	+
          count143	+
          count144	+
          count145	+
          count146	+
          count147	+
          count148	+
          count149	+
          count150;

    double avg = 0;
    avg = (double) sum / 150;
    cout << "avg error :: " << avg << endl;
    cout << "sum :: " << sum << endl;
}


void callfft() {

    const Complex test[] = {1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 2.0};
    CArray data(test, 8);

    // forward fft
    fft(data);

    std::cout << "fft" << std::endl;
    for (int i = 0; i < 8; ++i) {
        std::cout <<   setprecision(2) << data[i] << std::endl;
    }


}


void fft(CArray& x)
{
    const size_t N = x.size();
    if (N <= 1) return;



    // divide
    CArray even = x[std::slice(0, N/2, 2)];
    CArray  odd = x[std::slice(1, N/2, 2)];


    // conquer
    fft(even);
    fft(odd);

    // combine
    for (size_t k = 0; k < N/2; ++k)
    {
        Complex t = std::polar(1.0, -2 * PI * k / N) * odd[k];
        x[k    ] = even[k] + t;
        x[k+N/2] = even[k] - t;
    }
}



void customfft(){
    int N= 512;
    double x[8] = {1,1,1,1,2,2,2,2};
    double y[8] = {0,0,0,0,0,0,0,0};
    double dft_real[8] =  {0,0,0,0,0,0,0,0};
    double dft_imag[8] = {0,0,0,0,0,0,0,0};

    double sum_real =0;
    double sum_imag = 0;
        for(int k=0; k < N;k++)
        {

            //    cout << "k=" << k << "  ::::::::::" << endl;
            double sum_real =0;
            double sum_imag = 0;
            for(int m=0;m<=(N/2)-1;m++){
                double angle = 4*PI*k*m/N;
             //   cout << "m=" << m << "   ::::angle = " << angle << endl;
                //sum_real += x[2*m]*cos(angle) + y[2*m]*sin(angle);
                //sum_imag += -x[2*m]*sin(angle) + y[2*m]*cos(angle);
            }

            double sum_real1 =0;
            double sum_imag1 = 0;

            for(int m=0;m<=(N/2)-1;m++){
          //      double angle = 4*PI*k*m/N;
                //sum_real1 += x[(2*m)+1]*cos(angle) + y[(2*m)+1]*sin(angle);
                //sum_imag1 += -x[(2*m)+1]*sin(angle) + y[(2*m)+1]*cos(angle);
            }
            double angle = 2*PI*k/N;
          //  cout << "k=" << k << "   ::::angle = " << angle << endl;
            //dft_real[k] = sum_real + sum_real1*cos(angle) + sum_imag1*sin(angle);
           // dft_imag[k] = sum_imag - sum_real1*sin(angle) + sum_imag1*cos(angle);

        }
    cout << endl;

    for(int i=0;i<8;i++){
        cout << setprecision(2) << dft_real[i] << "::" << dft_imag[i] << endl;
    }
     double f1 = 56.4382;
    double f = f1*PI/180;

    cout << "sine value ::" << f-((f*f*f)/6) +((f*f*f*f*f)/120) << endl;


}
