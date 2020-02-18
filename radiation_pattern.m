function s = radiation_pattern (k0, d, K, theta)

s_a = array_factor(k0, d, K, theta);
s_e = element_factor(theta);
% s = real(s_e * s_a);
s = 20 * log10( abs(s_e) * abs(s_a) / K );

end