function theta = alpha_to_theta ( h, d, alpha_max, alpha )

Re = 6371e3;                % Radius of the Earth [m]
theta = real( asind( ( Re + h ) * sind( alpha_max / 2 - alpha ) ./ d ) );

end