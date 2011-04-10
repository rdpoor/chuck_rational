// file: rational_eg.ck -- example file for rational.ck class

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

