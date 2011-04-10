/*
File: rational.ck -- represent numbers as quotient of two integers.

=== Overview

The Rational class lets you represent numbers as a quotient of two
integers.  One advantage of rational representation is that precicion
is mainatained across arithmatic operations: 2/3 is really 2/3 and not
.6666667.

Supported operations are:

=> Conversion to/from other types:
   create(int i), create(float v), toFloat(), toString(), trunc(),
   floor(), ceil(), round()

=> comparison operations:
   signum(), cmp()

=> arithmetic operations:
   div(), mod(), abs(), negate(), reciprocal(), add(), sub(), mul(),
   quo()

Most operations are non-destructive -- they create a new rational
rather than modify the receiver -- but a number of operations include
versions that explicitly modify the receiver.  These are indicated by
a trailing '_' in the method name:

=> destructive opererations
   set_(), norm_(), abs_(), negate_(), reciprocal_(), add_(), sub_(),
   mul_(), quo_()

=== Rational approximation

Of special note is the internal method that converts a floating point
value to a rational.  We use a modified version of Farey's technique,
which is efficient and numerically stable.  The method allows you to
specify the largest permissable denominator used to approximate the
floating point value.  Even limiting the denominator to less than 1000
produces rational approximations that are very close to their
irrational counterparts, as can be seen in this example:

// file: rational_eg.ck

fun void test(float v, int dlimit) {
    Rational.create(v, dlimit) @=> Rational @ r;
    "Rational.create("+v+","+dlimit+")" => string label;
    <<< label, "~=", r.toString(), "~=", r.toFloat(), "err=", (r.toFloat()-v)*100/v, "%" >>>;
}

test(pi, 100);
test(pi, 1000);
test(pi, 10000);

Math.sqrt(10.0) => float SQRT_10;
test(SQRT_10, 100);
test(SQRT_10, 1000);
test(SQRT_10, 10000);

Math.pow(2.0, 1/12.0) => float SEMITONE;
test(SEMITONE, 100);
test(SEMITONE, 1000);
test(SEMITONE, 10000);

// ...which produces the following.  As you can see, even limiting the
// denominator to less than 1000 produces rational approximations that
// are very close to their irrational counterparts.

bash-3.2$ chuck rational.ck rational_eg.ck
Rational.create(3.1416,100) ~= 22/7 ~= 3.142857 err= 0.040250 % 
Rational.create(3.1416,1000) ~= 355/113 ~= 3.141593 err= 0.000008 % 
Rational.create(3.1416,10000) ~= 355/113 ~= 3.141593 err= 0.000008 % 
Rational.create(3.1623,100) ~= 117/37 ~= 3.162162 err= -0.003652 % 
Rational.create(3.1623,1000) ~= 721/228 ~= 3.162281 err= 0.000096 % 
Rational.create(3.1623,10000) ~= 27379/8658 ~= 3.162278 err= 0.000000 % 
Rational.create(1.0595,100) ~= 89/84 ~= 1.059524 err= 0.005731 % 
Rational.create(1.0595,1000) ~= 196/185 ~= 1.059459 err= -0.000343 % 
Rational.create(1.0595,10000) ~= 7893/7450 ~= 1.059463 err= -0.000001 % 

=== Suggestions, feedback, bugfixes or bugreports are welcome:
rdpoor (at) gmail (dot) com

=== Revision History:
rdpoor	15 Nov 2009: initial version.
=== End of Revision History

Copyright (c) 2009 Robert Poor

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.
*/

public class Rational {

    // ================================================================
    // class constants
    //
    // NOTE: to work around a ChucK design error (bug?), these constants
    // are initialized outside of the class definition at the bottom of
    // this file.

    static int CMP_LT;
    static int CMP_EQ;
    static int CMP_GT;
    static int DEFAULT_DLIMIT;

    // ================================================================
    // constructors
    //
    // Implementation note: We assume (and enforce) that Rational values
    // are always normalized.

    fun static Rational create(int i) {
	return create(i, 1);
    }
    fun static Rational create(float v) {
	return create(v, DEFAULT_DLIMIT);
    }
    fun static Rational create(float v, int dlimit) {
	return farey(v, dlimit);
    }
    fun static Rational create(Rational other) {
	return create(other.num(), other.den());
    }
    fun static Rational create(int n, int d) {
	return (new Rational).set_(n, d).norm_();
    }

    // ================================================================
    // (private) instance variables

    int _num;
    int _den;

    // ================================================================
    // (public) instance methods
    //
    // NOTE: methods names that end in '_' signify destructive operations:
    // they modify 'this'.  All others leave 'this' untouched.

    fun int num() { return _num; }
    fun int den() { return _den; }

    fun Rational set_(Rational other) { 
	return set_(other.num(), other.den());
    }

    fun Rational set_(int n, int d) {
	n => _num;
	d => _den;
	return this;
    }

    fun float toFloat() { return (num() $ float) / (den() $ float); }

    fun string toString() { return num() + "/" + den(); }

    // ================
    // operations with integer results

    // compare receiver against 0
    fun int signum() {	return ((num()==0)?CMP_EQ:(num()<0)?CMP_LT:CMP_GT); }

    // compare receiver against integer n
    fun int cmp(int i) {
	num() - (i * den()) => int n;
	return (n==0)?CMP_EQ:((n<0)?CMP_LT:CMP_GT);
    }

    // compare receiver against other Rational
    fun int cmp(Rational other) { return sub(other).signum(); }

    // trunc() returns the largest integer value no greater in
    // magnitude than the receiver ("round towards zero")
    //
    fun int trunc() { return num() / den(); }
    
    // floor() returns the largest integer not greater than the
    // receiver ("round towards minus infinity").
    //
    // Implementation note: floor(x) is the same as trunc(x), except
    // when the residual (x - trunc(x)) is less than zero, in which
    // case the result is trunc(x) - 1.
    //
    // Note that "((x - trunc(x)) < 0)" and "(x < trunc(x))" are
    // equivalent.  We use the latter form to take advantage of the
    // more efficient integer cmp() function.
    fun int floor() {
	trunc() => int trunc;
	return (cmp(trunc) == CMP_LT)?trunc-1:trunc;
    }

    // ceil() returns the smallest integer not less than the receiver
    // ("round towards plus infinity").
    //
    // Implementation note: floor(x) is the same as trunc(x), except
    // when the residual (x - trunc(x)) is greater than zero, in which
    // case the result is trunc(x) + 1.
    fun int ceil() {
	trunc() => int trunc;
	return (cmp(trunc) == CMP_GT)?trunc+1:trunc;
    }

    // round() returns the closest integer to the receiver, rounding
    // to even when the receiver is halfway between two integers.
    //
    // Implementation note: round(x) is the same as trunc(x), except
    // when the residual (x - trunc(x)) is less or equal to than -.5,
    // in which case the result is trunc(x)-1, or if the residual is
    // greater than or equal to +.5, in which case the result is
    // trunc(x)+1.
    //
    // We scale the receiver as well as the residual by a factor of 2
    // so we can use the more efficient integer cmp() operations.
    fun int round() {
	mul(2) @=> Rational @ twothis;
	trunc() => int trunc;
	if (twothis.cmp(2*(trunc-1)) != CMP_GT) {
	    return trunc-1;	// residual <= -0.5
	} else if (twothis.cmp(2*(trunc+1)) != CMP_LT) {
	    return trunc+1;	// residual >= 0.5
	} else {
	    return trunc;	// -0.5 < residual < 0.5
	}
    }

    // Truncating division.
    fun int div(Rational other) {
	return (num() * other.den()) / (den() * other.num());
    }

    fun int div(int i) {
	return num() / (den() * i);
    }

    fun Rational mod(Rational other) {
	div(other) => int div;
	return this.sub(other.mul(div));
    }

    fun Rational mod(int i) {
	div(i) => int div;
	return this.sub(i * div);
    }

    // ================
    // operations with Rational results

    // Normalize a Rational.  Guarantess that ratio is in 
    // lowest form (## what's the term for that? ##) and
    // that the denominator is always positive.
    fun Rational norm() { return norm(new Rational); }
    fun Rational norm_() { return norm(this); }
    fun Rational norm(Rational result) {
	num() => int num;
	den() => int den;

	if (num == 0) {
	    return result.set_(0, 1);
	} else if (den == 0) {
	    return result.set_(1, 0);
	}
	gcd(num, den) => int gcd;
	if (((gcd > 0) && (den < 0)) || ((gcd < 0) && (den > 0))){
	    -num => num;
	    -den => den;
	}
	return result.set_(num/gcd, den/gcd);
    }

    // result = abs(this)
    fun Rational abs() { return abs(new Rational); }
    fun Rational abs_() { return abs(this); }
    fun Rational abs(Rational result) {
	result.set_(this);
	if (signum() == -1) result.negate_();
	return result;
    }

    // result = - this
    fun Rational negate() { return negate(new Rational); }
    fun Rational negate_() { return negate(this); }
    fun Rational negate(Rational result) {
	return result.set_(-num(), den());
    }

    // result = 1 / this
    fun Rational reciprocal() { return reciprocal(new Rational); }
    fun Rational reciprocal_() { return reciprocal(this); }
    fun Rational reciprocal(Rational result) { 
	return result.set_(den(), num());
    }

    // result = this + other
    fun Rational add(Rational other) { return add(other, new Rational); }
    fun Rational add_(Rational other) { return add(other, this); }
    fun Rational add(Rational other, Rational result) {
	return result.set_(num() * other.den() + other.num() * den(), 
			   den() * other.den()).norm_();
    }
    fun Rational add(int i) { return add(i, new Rational); }
    fun Rational add_(int i) { return add(i, this); }
    fun Rational add(int i, Rational result) {
	return result.set_(num() + (i * den()), den()).norm_();
    }

    // result = this - other
    fun Rational sub(Rational other) { return sub(other, new Rational); }
    fun Rational sub_(Rational other) { return sub(other, this); }
    fun Rational sub(Rational other, Rational result) {
	return result.set_(num() * other.den() - other.num() * den(), 
			   den() * other.den()).norm_();
    }
    fun Rational sub(int i) { return sub(i, new Rational); }
    fun Rational sub_(int i) { return sub(i, this); }
    fun Rational sub(int i, Rational result) {
	return result.set_(num() - (i * den()), den()).norm_();
    }

    // result = this * other
    fun Rational mul(Rational other) { return mul(other, new Rational); }
    fun Rational mul_(Rational other) { return mul(other, this); }
    fun Rational mul(Rational other, Rational result) {
	return result.set_(num() * other.num(), den() * other.den()).norm_();
    }
    fun Rational mul(int i) { return mul(i, new Rational); }
    fun Rational mul_(int i) { return mul(i, this); }
    fun Rational mul(int i, Rational result) {
	return result.set_(num() * i, den()).norm_();
    }
	
    // result = this / other
    fun Rational quo(Rational other) { return quo(other, new Rational); }
    fun Rational quo_(Rational other) { return quo(other, this); }
    fun Rational quo(Rational other, Rational result) {
	return result.set_(num() * other.den(), den() * other.num()).norm_();
    }
    fun Rational quo(int i) { return quo(i, new Rational); }
    fun Rational quo_(int i) { return quo(i, this); }
    fun Rational quo(int i, Rational result) {
	return result.set_(num(), den() * i).norm_();
    }
	

    // ================================================================
    // private methods

    // Return the closest Rational that approximates float value v
    // with a denominator of less than or equal to dlim using Farey's
    // technique.
    //
    // Gratefully converted from vegaseat's code at:
    //   http://www.python-forum.org/pythonforum/viewtopic.php?f=2&t=5692
    // which, in turn was derived from:
    //   http://en.wikipedia.org/wiki/Farey_series
    // 
    fun static Rational farey(float v, int dlimit) {
	if (v < 0) return farey(-v, dlimit).negate_();

	Rational lower, upper, mediant;
	lower.set_(0, 1);
	upper.set_(1, 0);
	while (true) {
	    mediant.set_(lower.num() + upper.num(), lower.den() + upper.den());
	    if (v * mediant.den() > mediant.num()) {
		if (dlimit < mediant.den()) return upper;
		lower.set_(mediant);
	    } else if (v * mediant.den() == mediant.num()) {
		if (dlimit >= mediant.den()) return mediant;
		if (lower.den() < upper.den()) return lower;
		return upper;
	    } else {
		if (dlimit < mediant.den()) return lower;
		upper.set_(mediant);
	    }
	}
    }

    // Return GCD of integers a and b using Euclid's method
    //
    fun static int gcd(int a, int b) {
	if (b == 0) 
	    return a;
	else 
	    return gcd(b, a % b);
    }


    // Return LCM of integers a and b.
    // 
    // Implementation note: To avoid overflow, we distribute the
    // division of gcd rather than returning (a*b)/gcd
    // 
    fun static int lcm(int a, int b) {
	gcd(a, b) => int gcd;
	return (a/gcd) * (b/gcd);
    }

} // class Rational

// see note under "class constants" near top of class definition
-1 => Rational.CMP_LT;
0 => Rational.CMP_EQ;
1 => Rational.CMP_GT;
10000 => Rational.DEFAULT_DLIMIT;



// ================================================================
// testing...

// fun void t(float v) { t(v, Rational.DEFAULT_DLIMIT); }
// fun void t(float v, int dlimit) {
//     Rational.create(v, dlimit) @=> Rational @ f;
//     <<< f.toString(), f.toFloat(), v, f.toFloat()/v, f.toFloat() - v >>>;
// }

// t(pi, 100);
// t(pi, 1000);
// t(pi, 10000);
// t(pi, 100000);

// for (0 => int i; i<100; i++) {
//     t(Std.rand2f(-100.0, 100.0));
// }
