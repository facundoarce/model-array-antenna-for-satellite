function s_i = received_signal (f, k0, d, K, elem, theta, t)

w = 2 * pi * f;                                 % angular frequency
phi = k0 * ( K - elem ) * d * sind( theta );    % phase offset

s_i = real ( exp( 1j * ( w * t + phi ) ) );

end