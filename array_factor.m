function s_a = array_factor (k0, d, K, theta0, theta)

s_a = zeros(1, length(theta));
for elem = 1 : K
    s_a = s_a + exp( 1j * deg2rad(k0) * ( K - elem ) * d * ( sind( theta ) - sind(theta0) ) );
end

end