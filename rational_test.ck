// rational_test.ck: test suite for Rational class.
//
// Usage:
//	% chuck rational.ck rational_test.ck
// 
// Set errp (below) according to how much printing you want.
//
// Robert Poor <r@alum.mit.edu>, October 2009

// control what gets printed
0 => int PRINT_ALL;
1 => int PRINT_ERRORS;
2 => int PRINT_NONE;
PRINT_ERRORS => int errp;
// PRINT_ALL => int errp;

fun int do_test(string testname, int got, int expected) {
    if (expected == got) {
	if (errp == PRINT_ALL) <<< testname, ": okay" >>>;
	return 0;
    } else {
	if (errp != PRINT_NONE) <<< testname, ": got:", got, "expected:", expected >>>;
	return 1;
    }
}

fun int do_test(string testname, float got, float expected) {
    if (expected == got) {
	if (errp == PRINT_ALL) <<< testname, ": okay" >>>;
	return 0;
    } else {
	if (errp != PRINT_NONE) <<< testname, ": got:", got, "expected:", expected >>>;
	return 1;
    }
}

fun int do_test(string testname, string got, string expected) {
    if (expected == got) {
	if (errp == PRINT_ALL) <<< testname, ": okay" >>>;
	return 0;
    } else {
	if (errp != PRINT_NONE) <<< testname, ": got:", got, "expected:", expected >>>;
	return 1;
    }
}

fun int do_test(string testname, Rational got, Rational expected) {
    if (expected.cmp(got) == Rational.CMP_EQ) {
	if (errp == PRINT_ALL) <<< testname, ": okay" >>>;
	return 0;
    } else {
	if (errp != PRINT_NONE) <<< testname, ": got:", got.toString(), "expected:", expected.toString() >>>;
	return 1;
    }
}

// Define a few constant Rationals

Rational.create(-2) @=> Rational @ M_TWO;
Rational.create(-1) @=> Rational @ M_ONE;
Rational.create(-1, 2) @=> Rational @ M_HALF;
Rational.create(0) @=> Rational @ ZERO;
Rational.create(1, 2) @=> Rational @ HALF;
Rational.create(1) @=> Rational @ ONE;
Rational.create(2) @=> Rational @ TWO;
Rational.create(Math.sqrt(2.0)) @=> Rational SQRT_2;

// Test basic printing
<<< "Defined constant Rational values:" >>>;
<<< "M_TWO:", M_TWO.toString() >>>;
<<< "M_ONE:", M_ONE.toString() >>>;
<<< "M_HALF:", M_HALF.toString() >>>;
<<< "ZERO:", ZERO.toString() >>>;
<<< "HALF:", HALF.toString() >>>;
<<< "ONE:", ONE.toString() >>>;
<<< "TWO:", TWO.toString() >>>;
<<< "SQRT_2:", SQRT_2.toString() >>>;

// Test floating point constructor
do_test("Rational.create(-2.0)", Rational.create(-2.0), M_TWO);
do_test("Rational.create(-1.0)", Rational.create(-1.0), M_ONE);
do_test("Rational.create(-0.5)", Rational.create(-0.5), M_HALF);
// -0.0 should normalize to be 0,0
do_test("Rational.create(-0.0)", Rational.create(-0.0), ZERO);
do_test("Rational.create(0.0)", Rational.create(0.0), ZERO);
do_test("Rational.create(0.5)", Rational.create(0.5), HALF);
do_test("Rational.create(1.0)", Rational.create(1.0), ONE);
do_test("Rational.create(2.0)", Rational.create(2.0), TWO);

// Test some famous values
do_test("Rational.create(pi, 100)", Rational.create(pi, 100), Rational.create(22,7));
do_test("Rational.create(pi, 1000)", Rational.create(pi, 1000), Rational.create(355,113));
do_test("Rational.create(pi, 10000)", Rational.create(pi, 10000), Rational.create(355,113));
do_test("Rational.create(pi, 100000)", Rational.create(pi, 100000), Rational.create(312689,99532));

// Test copying constructor
do_test("Rational.create(TWO).cmp(TWO)", Rational.create(TWO).cmp(TWO), Rational.CMP_EQ);

// Test num, den constructor, verify normalization
do_test("Rational.create(1, 2).cmp(HALF)", Rational.create(1, 2).cmp(HALF), Rational.CMP_EQ);
do_test("Rational.create(2, 4).cmp(HALF)", Rational.create(2, 4).cmp(HALF), Rational.CMP_EQ);
do_test("Rational.create(-20, -40).cmp(HALF)", Rational.create(-20, -40).cmp(HALF), Rational.CMP_EQ);
do_test("Rational.create(-2, 4).cmp(M_HALF)", Rational.create(-2, 4).cmp(M_HALF), Rational.CMP_EQ);
do_test("Rational.create(2, -4).cmp(M_HALF)", Rational.create(2, -4).cmp(M_HALF), Rational.CMP_EQ);

for (-6 => int n; n <= 6; n++) {
    for (-6 => int d; d <= 6; d++) {
	// verify that denominator never has negative sign
	Rational.create(n, d) @=> Rational @ r;
	"Rational.create("+n+","+d+").den() >= 0" => string label;
	do_test(label, r.den() >= 0, true);
	// verify that n/d is in reduced form
    }
}


// test num(), den()
do_test("Rational.create(pi, 1000).num()", Rational.create(pi, 1000).num(), 355);
do_test("Rational.create(pi, 1000).den()", Rational.create(pi, 1000).den(), 113);

// test converstion to float and to string
do_test("Rational.create(3, 4).toFloat()", Rational.create(3, 4).toFloat(), 0.75);
do_test("Rational.create(3, 4).toString()", Rational.create(3, 4).toString(), "3/4");

// signum
do_test("M_HALF.signum()", M_HALF.signum(), Rational.CMP_LT);
do_test("ZERO.signum()", ZERO.signum(), Rational.CMP_EQ);
do_test("HALF.signum()", HALF.signum(), Rational.CMP_GT);

// compare against integer
do_test("M_ONE.cmp(-2)", M_ONE.cmp(-2), Rational.CMP_GT);
do_test("M_ONE.cmp(-1)", M_ONE.cmp(-1), Rational.CMP_EQ);
do_test("M_ONE.cmp(0)", M_ONE.cmp(0), Rational.CMP_LT);
do_test("ONE.cmp(0)", ONE.cmp(0), Rational.CMP_GT);
do_test("ONE.cmp(1)", ONE.cmp(1), Rational.CMP_EQ);
do_test("ONE.cmp(2)", ONE.cmp(2), Rational.CMP_LT);

// compare against Rational
do_test("ONE.cmp(SQRT_2)", ONE.cmp(SQRT_2), Rational.CMP_LT);
do_test("TWO.cmp(SQRT_2)", TWO.cmp(SQRT_2), Rational.CMP_GT);
do_test("SQRT_2.cmp(ONE)", SQRT_2.cmp(ONE), Rational.CMP_GT);
do_test("SQRT_2.cmp(TWO)", SQRT_2.cmp(TWO), Rational.CMP_LT);

// trunc
do_test("M_TWO.trunc()", M_TWO.trunc(), -2);
do_test("M_ONE.trunc()", M_ONE.trunc(), -1);
do_test("M_HALF.trunc()", M_HALF.trunc(), 0);
do_test("ZERO.trunc()", ZERO.trunc(), 0);
do_test("HALF.trunc()", HALF.trunc(), 0);
do_test("ONE.trunc()", ONE.trunc(), 1);
do_test("TWO.trunc()", TWO.trunc(), 2);
do_test("SQRT_2.trunc()", SQRT_2.trunc(), 1);

// floor
do_test("M_TWO.floor()", M_TWO.floor(), -2);
do_test("M_ONE.floor()", M_ONE.floor(), -1);
do_test("M_HALF.floor()", M_HALF.floor(), -1);
do_test("ZERO.floor()", ZERO.floor(), 0);
do_test("HALF.floor()", HALF.floor(), 0);
do_test("ONE.floor()", ONE.floor(), 1);
do_test("TWO.floor()", TWO.floor(), 2);
do_test("SQRT_2.floor()", SQRT_2.floor(), 1);

// ceil
do_test("M_TWO.ceil()", M_TWO.ceil(), -2);
do_test("M_ONE.ceil()", M_ONE.ceil(), -1);
do_test("M_HALF.ceil()", M_HALF.ceil(), 0);
do_test("ZERO.ceil()", ZERO.ceil(), 0);
do_test("HALF.ceil()", HALF.ceil(), 1);
do_test("ONE.ceil()", ONE.ceil(), 1);
do_test("TWO.ceil()", TWO.ceil(), 2);
do_test("SQRT_2.ceil()", SQRT_2.ceil(), 2);

// round
do_test("M_TWO.round()", M_TWO.round(), -2);
do_test("M_ONE.round()", M_ONE.round(), -1);
do_test("M_HALF.round()", M_HALF.round(), 0);
do_test("ZERO.round()", ZERO.round(), 0);
do_test("HALF.round()", HALF.round(), 0);
do_test("ONE.round()", ONE.round(), 1);
do_test("TWO.round()", TWO.round(), 2);
do_test("SQRT_2.round()", SQRT_2.round(), 1);

// ### div, mod need testing

// abs
do_test("M_TWO.abs().cmp(TWO)", M_TWO.abs().cmp(TWO), Rational.CMP_EQ);
do_test("M_ONE.abs().cmp(ONE)", M_ONE.abs().cmp(ONE), Rational.CMP_EQ);
do_test("M_HALF.abs().cmp(HALF)", M_HALF.abs().cmp(HALF), Rational.CMP_EQ);
do_test("ZERO.abs().cmp(ZERO)", ZERO.abs().cmp(ZERO), Rational.CMP_EQ);
do_test("ONE.abs().cmp(ONE)", ONE.abs().cmp(ONE), Rational.CMP_EQ);
do_test("TWO.abs().cmp(TWO)", TWO.abs().cmp(TWO), Rational.CMP_EQ);

// negate
do_test("M_TWO.negate().cmp(TWO)", M_TWO.negate().cmp(TWO), Rational.CMP_EQ);
do_test("M_ONE.negate().cmp(ONE)", M_ONE.negate().cmp(ONE), Rational.CMP_EQ);
do_test("M_HALF.negate().cmp(HALF)", M_HALF.negate().cmp(HALF), Rational.CMP_EQ);
do_test("ZERO.negate().cmp(ZERO)", ZERO.negate().cmp(ZERO), Rational.CMP_EQ);
do_test("ONE.negate().cmp(M_ONE)", ONE.negate().cmp(M_ONE), Rational.CMP_EQ);
do_test("TWO.negate().cmp(M_TWO)", TWO.negate().cmp(M_TWO), Rational.CMP_EQ);

// reciprocal
do_test("M_TWO.reciprocal().cmp(M_HALF)", M_TWO.reciprocal().cmp(M_HALF), Rational.CMP_EQ);
do_test("M_ONE.reciprocal().cmp(M_ONE)", M_ONE.reciprocal().cmp(M_ONE), Rational.CMP_EQ);
do_test("M_HALF.reciprocal().cmp(M_TWO)", M_HALF.reciprocal().cmp(M_TWO), Rational.CMP_EQ);
// do_test("ZERO.reciprocal().cmp(ZERO)", ZERO.reciprocal().cmp(ZERO), Rational.CMP_EQ);
do_test("ONE.reciprocal().cmp(ONE)", ONE.reciprocal().cmp(ONE), Rational.CMP_EQ);
do_test("TWO.reciprocal().cmp(HALF)", TWO.reciprocal().cmp(HALF), Rational.CMP_EQ);

// add
// -2, -1, -.5, 0, .5, 1, 2
//
do_test("M_TWO.add(ONE).cmp(M_ONE)", M_TWO.add(ONE).cmp(M_ONE), Rational.CMP_EQ);
do_test("M_TWO.add(TWO).cmp(ZERO)", M_TWO.add(TWO).cmp(ZERO), Rational.CMP_EQ);
do_test("M_ONE.add(HALF).cmp(M_HALF)", M_ONE.add(HALF).cmp(M_HALF), Rational.CMP_EQ);
do_test("M_ONE.add(ONE).cmp(ZERO)", M_ONE.add(ONE).cmp(ZERO), Rational.CMP_EQ);
do_test("M_ONE.add(TWO).cmp(ONE)", M_ONE.add(TWO).cmp(ONE), Rational.CMP_EQ);
do_test("M_HALF.add(HALF).cmp(ZERO)", M_HALF.add(HALF).cmp(ZERO), Rational.CMP_EQ);
do_test("ZERO.add(M_TWO).cmp(M_TWO)", ZERO.add(M_TWO).cmp(M_TWO), Rational.CMP_EQ);
do_test("ZERO.add(M_ONE).cmp(M_ONE)", ZERO.add(M_ONE).cmp(M_ONE), Rational.CMP_EQ);
do_test("ZERO.add(M_HALF).cmp(M_HALF)", ZERO.add(M_HALF).cmp(M_HALF), Rational.CMP_EQ);
do_test("ZERO.add(ZERO).cmp(ZERO)", ZERO.add(ZERO).cmp(ZERO), Rational.CMP_EQ);
do_test("ZERO.add(HALF).cmp(HALF)", ZERO.add(HALF).cmp(HALF), Rational.CMP_EQ);
do_test("ZERO.add(ONE).cmp(ONE)", ZERO.add(ONE).cmp(ONE), Rational.CMP_EQ);
do_test("ZERO.add(TWO).cmp(TWO)", ZERO.add(TWO).cmp(TWO), Rational.CMP_EQ);
do_test("HALF.add(M_HALF).cmp(ZERO)", HALF.add(M_HALF).cmp(ZERO), Rational.CMP_EQ);
do_test("ONE.add(M_TWO).cmp(M_ONE)", ONE.add(M_TWO).cmp(M_ONE), Rational.CMP_EQ);
do_test("ONE.add(M_ONE).cmp(ZERO)", ONE.add(M_ONE).cmp(ZERO), Rational.CMP_EQ);
do_test("ONE.add(M_HALF).cmp(HALF)", ONE.add(M_HALF).cmp(HALF), Rational.CMP_EQ);
do_test("ONE.add(ZERO).cmp(ONE)", ONE.add(ZERO).cmp(ONE), Rational.CMP_EQ);
do_test("ONE.add(ONE).cmp(TWO)", ONE.add(ONE).cmp(TWO), Rational.CMP_EQ);
do_test("TWO.add(M_TWO).cmp(ZERO)", TWO.add(M_TWO).cmp(ZERO), Rational.CMP_EQ);
do_test("TWO.add(M_ONE).cmp(ONE)", TWO.add(M_ONE).cmp(ONE), Rational.CMP_EQ);
do_test("TWO.add(ZERO).cmp(TWO)", TWO.add(ZERO).cmp(TWO), Rational.CMP_EQ);
;;
do_test("M_TWO.add(0).cmp(M_TWO)", M_TWO.add(0).cmp(M_TWO), Rational.CMP_EQ);
do_test("M_TWO.add(1).cmp(M_ONE)", M_TWO.add(1).cmp(M_ONE), Rational.CMP_EQ);
do_test("M_TWO.add(2).cmp(ZERO)", M_TWO.add(2).cmp(ZERO), Rational.CMP_EQ);
do_test("M_TWO.add(3).cmp(ONE)", M_TWO.add(3).cmp(ONE), Rational.CMP_EQ);
do_test("M_TWO.add(4).cmp(TWO)", M_TWO.add(4).cmp(TWO), Rational.CMP_EQ);
do_test("M_ONE.add(-1).cmp(M_TWO)", M_ONE.add(-1).cmp(M_TWO), Rational.CMP_EQ);
do_test("M_ONE.add(0).cmp(M_ONE)", M_ONE.add(0).cmp(M_ONE), Rational.CMP_EQ);
do_test("M_ONE.add(1).cmp(ZERO)", M_ONE.add(1).cmp(ZERO), Rational.CMP_EQ);
do_test("M_ONE.add(2).cmp(ONE)", M_ONE.add(2).cmp(ONE), Rational.CMP_EQ);
do_test("M_ONE.add(3).cmp(TWO)", M_ONE.add(3).cmp(TWO), Rational.CMP_EQ);
do_test("M_HALF.add(1).cmp(HALF)", M_HALF.add(1).cmp(HALF), Rational.CMP_EQ);
do_test("ZERO.add(-2).cmp(M_TWO)", ZERO.add(-2).cmp(M_TWO), Rational.CMP_EQ);
do_test("ZERO.add(-1).cmp(M_ONE)", ZERO.add(-1).cmp(M_ONE), Rational.CMP_EQ);
do_test("ZERO.add(0).cmp(ZERO)", ZERO.add(0).cmp(ZERO), Rational.CMP_EQ);
do_test("ZERO.add(1).cmp(ONE)", ZERO.add(1).cmp(ONE), Rational.CMP_EQ);
do_test("ZERO.add(2).cmp(TWO)", ZERO.add(2).cmp(TWO), Rational.CMP_EQ);
do_test("ONE.add(-3).cmp(M_TWO)", ONE.add(-3).cmp(M_TWO), Rational.CMP_EQ);
do_test("ONE.add(-2).cmp(M_ONE)", ONE.add(-2).cmp(M_ONE), Rational.CMP_EQ);
do_test("ONE.add(-1).cmp(ZERO)", ONE.add(-1).cmp(ZERO), Rational.CMP_EQ);
do_test("ONE.add(0).cmp(ONE)", ONE.add(0).cmp(ONE), Rational.CMP_EQ);
do_test("ONE.add(1).cmp(TWO)", ONE.add(1).cmp(TWO), Rational.CMP_EQ);
do_test("HALF.add(-1).cmp(M_HALF)", HALF.add(-1).cmp(M_HALF), Rational.CMP_EQ);
do_test("TWO.add(-4).cmp(M_TWO)", TWO.add(-4).cmp(M_TWO), Rational.CMP_EQ);
do_test("TWO.add(-3).cmp(M_ONE)", TWO.add(-3).cmp(M_ONE), Rational.CMP_EQ);
do_test("TWO.add(-2).cmp(ZERO)", TWO.add(-2).cmp(ZERO), Rational.CMP_EQ);
do_test("TWO.add(-1).cmp(ONE)", TWO.add(-1).cmp(ONE), Rational.CMP_EQ);
do_test("TWO.add(0).cmp(TWO)", TWO.add(0).cmp(TWO), Rational.CMP_EQ);

// sub
// -2, -1, -.5, 0, .5, 1, 2
//
do_test("M_TWO.sub(M_TWO).cmp(ZERO)", M_TWO.sub(M_TWO).cmp(ZERO), Rational.CMP_EQ);
do_test("M_TWO.sub(M_ONE).cmp(M_ONE)", M_TWO.sub(M_ONE).cmp(M_ONE), Rational.CMP_EQ);
do_test("M_TWO.sub(ZERO).cmp(M_TWO)", M_TWO.sub(ZERO).cmp(M_TWO), Rational.CMP_EQ);
do_test("M_ONE.sub(M_TWO).cmp(ONE)", M_ONE.sub(M_TWO).cmp(ONE), Rational.CMP_EQ);
do_test("M_ONE.sub(M_ONE).cmp(ZERO)", M_ONE.sub(M_ONE).cmp(ZERO), Rational.CMP_EQ);
do_test("M_ONE.sub(ZERO).cmp(M_ONE)", M_ONE.sub(ZERO).cmp(M_ONE), Rational.CMP_EQ);
do_test("M_ONE.sub(ONE).cmp(M_TWO)", M_ONE.sub(ONE).cmp(M_TWO), Rational.CMP_EQ);
do_test("M_HALF.sub(M_ONE).cmp(HALF)", M_HALF.sub(M_ONE).cmp(HALF), Rational.CMP_EQ);
do_test("ZERO.sub(M_TWO).cmp(TWO)", ZERO.sub(M_TWO).cmp(TWO), Rational.CMP_EQ);
do_test("ZERO.sub(M_ONE).cmp(ONE)", ZERO.sub(M_ONE).cmp(ONE), Rational.CMP_EQ);
do_test("ZERO.sub(ZERO).cmp(ZERO)", ZERO.sub(ZERO).cmp(ZERO), Rational.CMP_EQ);
do_test("ZERO.sub(ONE).cmp(M_ONE)", ZERO.sub(ONE).cmp(M_ONE), Rational.CMP_EQ);
do_test("ZERO.sub(TWO).cmp(M_TWO)", ZERO.sub(TWO).cmp(M_TWO), Rational.CMP_EQ);
do_test("HALF.sub(ONE).cmp(M_HALF)", HALF.sub(ONE).cmp(M_HALF), Rational.CMP_EQ);
do_test("ONE.sub(M_ONE).cmp(TWO)", ONE.sub(M_ONE).cmp(TWO), Rational.CMP_EQ);
do_test("ONE.sub(ZERO).cmp(ONE)", ONE.sub(ZERO).cmp(ONE), Rational.CMP_EQ);
do_test("ONE.sub(ONE).cmp(ZERO)", ONE.sub(ONE).cmp(ZERO), Rational.CMP_EQ);
do_test("ONE.sub(TWO).cmp(M_ONE)", ONE.sub(TWO).cmp(M_ONE), Rational.CMP_EQ);
do_test("TWO.sub(ZERO).cmp(TWO)", TWO.sub(ZERO).cmp(TWO), Rational.CMP_EQ);
do_test("TWO.sub(ONE).cmp(ONE)", TWO.sub(ONE).cmp(ONE), Rational.CMP_EQ);
do_test("TWO.sub(TWO).cmp(ZERO)", TWO.sub(TWO).cmp(ZERO), Rational.CMP_EQ);
;;
do_test("M_TWO.sub(0).cmp(M_TWO)", M_TWO.sub(0).cmp(M_TWO), Rational.CMP_EQ);
do_test("M_TWO.sub(-1).cmp(M_ONE)", M_TWO.sub(-1).cmp(M_ONE), Rational.CMP_EQ);
do_test("M_TWO.sub(-2).cmp(ZERO)", M_TWO.sub(-2).cmp(ZERO), Rational.CMP_EQ);
do_test("M_TWO.sub(-3).cmp(ONE)", M_TWO.sub(-3).cmp(ONE), Rational.CMP_EQ);
do_test("M_TWO.sub(-4).cmp(TWO)", M_TWO.sub(-4).cmp(TWO), Rational.CMP_EQ);
do_test("M_ONE.sub(1).cmp(M_TWO)", M_ONE.sub(1).cmp(M_TWO), Rational.CMP_EQ);
do_test("M_ONE.sub(0).cmp(M_ONE)", M_ONE.sub(0).cmp(M_ONE), Rational.CMP_EQ);
do_test("M_ONE.sub(-1).cmp(ZERO)", M_ONE.sub(-1).cmp(ZERO), Rational.CMP_EQ);
do_test("M_ONE.sub(-2).cmp(ONE)", M_ONE.sub(-2).cmp(ONE), Rational.CMP_EQ);
do_test("M_ONE.sub(-3).cmp(TWO)", M_ONE.sub(-3).cmp(TWO), Rational.CMP_EQ);
do_test("M_HALF.sub(-1).cmp(HALF)", M_HALF.sub(-1).cmp(HALF), Rational.CMP_EQ);
do_test("ZERO.sub(2).cmp(M_TWO)", ZERO.sub(2).cmp(M_TWO), Rational.CMP_EQ);
do_test("ZERO.sub(1).cmp(M_ONE)", ZERO.sub(1).cmp(M_ONE), Rational.CMP_EQ);
do_test("ZERO.sub(0).cmp(ZERO)", ZERO.sub(0).cmp(ZERO), Rational.CMP_EQ);
do_test("ZERO.sub(-1).cmp(ONE)", ZERO.sub(-1).cmp(ONE), Rational.CMP_EQ);
do_test("ZERO.sub(-2).cmp(TWO)", ZERO.sub(-2).cmp(TWO), Rational.CMP_EQ);
do_test("ONE.sub(3).cmp(M_TWO)", ONE.sub(3).cmp(M_TWO), Rational.CMP_EQ);
do_test("ONE.sub(2).cmp(M_ONE)", ONE.sub(2).cmp(M_ONE), Rational.CMP_EQ);
do_test("ONE.sub(1).cmp(ZERO)", ONE.sub(1).cmp(ZERO), Rational.CMP_EQ);
do_test("ONE.sub(0).cmp(ONE)", ONE.sub(0).cmp(ONE), Rational.CMP_EQ);
do_test("ONE.sub(-1).cmp(TWO)", ONE.sub(-1).cmp(TWO), Rational.CMP_EQ);
do_test("HALF.sub(1).cmp(M_HALF)", HALF.sub(1).cmp(M_HALF), Rational.CMP_EQ);
do_test("TWO.sub(4).cmp(M_TWO)", TWO.sub(4).cmp(M_TWO), Rational.CMP_EQ);
do_test("TWO.sub(3).cmp(M_ONE)", TWO.sub(3).cmp(M_ONE), Rational.CMP_EQ);
do_test("TWO.sub(2).cmp(ZERO)", TWO.sub(2).cmp(ZERO), Rational.CMP_EQ);
do_test("TWO.sub(1).cmp(ONE)", TWO.sub(1).cmp(ONE), Rational.CMP_EQ);
do_test("TWO.sub(0).cmp(TWO)", TWO.sub(0).cmp(TWO), Rational.CMP_EQ);

// a mess o' multiplies
//
for (-6 => int n1; n1 <= 6; n1++) {
    for (-6 => int d1; d1 <= 6; d1++) {
	for (-6 => int n2; n2 <= 6; n2++) {
	    for (-6 => int d2; d2 <= 6; d2++) {
		if ((d1 != 0) && (d2 != 0)) {
		    Rational.create(n1, d1) @=> Rational @ r1;
		    Rational.create(n2, d2) @=> Rational @ r2;
		    r1.mul(r2) @=> Rational @ r3;
		    ((n1 * n2) $ float) / ((d1 * d2) $ float) => float f3;
		    "("+r1.toString()+")*("+r2.toString()+")=("+r3.toString()+")="+f3 =>  string label;
		    do_test(label, r3.toFloat() == f3, true);
		}
	    }
	}
    }
}

// similar, but with integer multiplication
//
for (-6 => int n1; n1 <= 6; n1++) {
    for (-6 => int d1; d1 <= 6; d1++) {
	for (-6 => int i2; i2 <= 6; i2++) {
	    if (d1 != 0) {
		Rational.create(n1, d1) @=> Rational @ r1;
		r1.mul(i2) @=> Rational @ r3;
		((n1 * i2) $ float) / (d1 $ float) => float f3;
		"("+r1.toString()+")*"+i2+"=("+r3.toString()+")="+f3 =>  string label;
		do_test(label, r3.toFloat() == f3, true);
	    }
	}
    }
}


// a mess o' divides
//
for (-6 => int n1; n1 <= 6; n1++) {
    for (-6 => int d1; d1 <= 6; d1++) {
	for (-6 => int n2; n2 <= 6; n2++) {
	    for (-6 => int d2; d2 <= 6; d2++) {
		if ((d1 != 0) && (d2 != 0) && (n2 != 0)) {
		    Rational.create(n1, d1) @=> Rational @ r1;
		    Rational.create(n2, d2) @=> Rational @ r2;
		    r1.quo(r2) @=> Rational @ r3;
		    ((n1 * d2) $ float) / ((d1 * n2) $ float) => float f3;
		    "("+r1.toString()+")/("+r2.toString()+")=("+r3.toString()+")="+f3 =>  string label;
		    do_test(label, r3.toFloat() == f3, true);
		}
	    }
	}
    }
}

// PRINT_ALL => errp;

// similar, but with integer division
//
for (-6 => int n1; n1 <= 6; n1++) {
    for (-6 => int d1; d1 <= 6; d1++) {
	for (-6 => int i2; i2 <= 6; i2++) {
	    if ((d1 != 0) && (i2 != 0)) {
		Rational.create(n1, d1) @=> Rational @ r1;
		r1.quo(i2) @=> Rational @ r3;
		(n1 $ float) / ((d1 * i2) $ float) => float f3;
		"("+r1.toString()+")/"+i2+"=("+r3.toString()+")="+f3 =>  string label;
		do_test(label, r3.toFloat() == f3, true);
	    }
	}
    }
}


