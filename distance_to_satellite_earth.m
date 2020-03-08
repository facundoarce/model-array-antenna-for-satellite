function d = distance_to_satellite_earth (h, alpha_max, alpha)

Re = 6371e3;    % Radius of the Earth [m]
d = sqrt( ( Re + h )^2 + Re^2 - 2 * ( Re + h ) * Re * cosd( alpha_max / 2 - alpha ) );

end