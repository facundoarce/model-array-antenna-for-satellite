function s = radiation_pattern (s_a, s_e, K)

s = 20 * log10( abs(s_e) .* abs(s_a) / K );

end