AN ALTERNATE TEST DISTRIBUTION: REVERSE.SAS  (by P.R. Jemian)
================================================================


A new, alternate test distribution, REVERSE, has been created by P.R.
Jemian to test several key questions:

#1. How close can the program get to a known volume fraction?

        Note that there is no specification for the exact answer
        of total volume fraction for BIMODAL.SAS, only a normalized
        distribution [Culverwell, 1986].

#2. Does MaxSas handle data in the size range of a double-crystal intrument?
#3. Do the solved distributions always look the same?

The distribution is (once again) two Gaussians in f(D) space where the
Gaussian at lower diameter (1100 A, sigma = 300) is 25% the height of
the other Gaussian (3400 A, sigma = 680).  REVERSE.DIS is the starting
distribution, from which is calculated the scattering (REVERSE.SAS)
using the exact form factor for spheres.  An artificial volume
fraction of 1.5%, artificial scattering contrast of 10.0E28 1/m**4, an
artificial background of 5.0 1/cm, and artificial random noise of 4%
were added to the data.  A summary of the analysis of the REVERSE.SAS
dataset follows:


SUMMARY OF MAXSAS ANALYSIS OF REVERSE.SAS
--------------------------------------------

======================  =============    ============
term                    analysis         actual
======================  =============    ============
qMin                    0.0005           ---
qMax                    0.025            ---
NumPts                     24            ---
ChiSquared              23.972           ---
Dmin                       80            ---
Dmax                     8000            ---
NumBins                   100            ---
flat entropy             4.605           ---
entropy                  3.925           ---
Total vol. frac.         1.436%          1.5%
suggested background     4.78            5.0
vol-mean diameter        3231            3172
number-mean diameter     1181             905
error scaling factor      1.0             1.0
======================  =============    ============

It appears that the spheres model can deliver the character of the
correct distribution and volume fraction.

While the oscillations in the distribution suggest that there is
statistical evidence for such irregular features, these cannot be
believed as we know, a priori, the starting distribution and that
distribution is smooth.  We must conclude therefore that the entropy
is not adequately maximized, subject to the constraint that ChiSquared
equals the number of intensity points.  While decreasing the maximum
value allowed for TEST (currently set at 0.05) might seem to produce a
better alignment between the entropy and ChiSquared gradients, a value
as low as 0.0001 does not seem to alter the final entropy more than
about 0.5%.  A discussion with G.J. Daniell might bring us to resolve
this point.  Probably the oscillations have an origin in the
introduction of the baseline "b" into the definition of the entropy as
done by [Skilling, 1984].  This simplifies the math when calculating
the entropy gradients but that probably makes the algorithm of
[Skilling, 1984] very sensitive to gradients in the form factor.

One method to circumvent this unsightly "noise" in the solved
distributions has been to replace the form factors that are defined
with trig terms by ones defined by algebra.  These approximations are
only as good as the algebraic form can model the scattering and can
render truly fictional volume fractions in the worst possible cases.

To answer, then, the three questions above, the volume fraction of the
solution was very close to the actual volume fraction.  The mean
diameter was also very close, with the volume-weighted mean being the
closest.  The solved distribution was very close to the input
distribution which differed dramatically in shape to the distribution
of BIMODAL.SAS, hence the solved distributions do not always look
alike.  The range of diameters in the distribution for REVERSE.SAS was
in the range of the double-crystal instrument and so that question can
be answered affirmatively.  The answers are also believable and so
MaxSas is not limited by the experimental range of a particular type
of scattering camera.
