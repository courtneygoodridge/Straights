
%stolen from an Octave script at http://code.metager.de/source/xref/gnu/octave/scripts/statistics/distributions/normpdf.m
function pdf = normpdf (x, mu, sigma)

%     if (nargin != 1 && nargin != 3)
%        print_usage ();
%     end

%     if (!isscalar (mu) || !isscalar (sigma))
%        [retval, x, mu, sigma] = common_size (x, mu, sigma);
%        if (retval > 0)
%           error ("normpdf: X, MU, and SIGMA must be of common size or scalars");
%        end
%     end

%     if (iscomplex (x) || iscomplex (mu) || iscomplex (sigma))
%         error ("normpdf: X, MU, and SIGMA must not be complex");
%     end

%     if (isa (x, "single") || isa (mu, "single") || isa (sigma, "single"))
%        pdf = zeros (size (x), 1);
%     else
%        pdf = zeros (size (x));
%     end

%     pdf = zeros (size (x),1);
    if (isscalar (mu) && isscalar (sigma))
      if (isfinite (mu) && (sigma > 0) && (sigma < Inf))
         x2 = (x - mu) ./ sigma;
         stdnormalpdf = (2 * pi)^(- 1/2) * exp (- x2 .^ 2 / 2);
         pdf = stdnormalpdf / sigma;
      else
         pdf = NaN (size (x), class (pdf));
      end
    else                  
      x2 = (x(k) - mu(k)) ./ sigma(k);
      stdnormalpdf = (2 * pi)^(- 1/2) * exp (- x2 .^ 2 / 2);
      pdf(k) = stdnormalpdf ./ sigma(k);
      
    end

end

%!shared x,y
%! x = [-Inf 1 2 Inf];
%! y = 1/sqrt(2*pi)*exp (-(x-1).^2/2);
%!assert (normpdf (x, ones (1,4), ones (1,4)), y)
%!assert (normpdf (x, 1, ones (1,4)), y)
%!assert (normpdf (x, ones (1,4), 1), y)
%!assert (normpdf (x, [0 -Inf NaN Inf], 1), [y(1) NaN NaN NaN])
%!assert (normpdf (x, 1, [Inf NaN -1 0]), [NaN NaN NaN NaN])
%!assert (normpdf ([x, NaN], 1, 1), [y, NaN])

%% Test class of input preserved
%!assert (normpdf (single ([x, NaN]), 1, 1), single ([y, NaN]), eps ("single"))
%!assert (normpdf ([x, NaN], single (1), 1), single ([y, NaN]), eps ("single"))
%!assert (normpdf ([x, NaN], 1, single (1)), single ([y, NaN]), eps ("single"))

%% Test input validation
%!error normpdf ()
%!error normpdf (1,2)
%!error normpdf (1,2,3,4)
%!error normpdf (ones (3), ones (2), ones (2))
%!error normpdf (ones (2), ones (3), ones (2))
%!error normpdf (ones (2), ones (2), ones (3))
%!error normpdf (i, 2, 2)
%!error normpdf (2, i, 2)
%!error normpdf (2, 2, i)
