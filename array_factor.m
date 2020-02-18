function s_a = array_factor (k0, d, K, theta)

s_a = 0;
for elem = 1 : K
    s_a = s_a + exp( 1j * k0 * ( K - elem ) * d * sind( theta ) );
end

end