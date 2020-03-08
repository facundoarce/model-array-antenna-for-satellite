function d = distance_to_satellite_antenna (h, theta)

Re = 6371e3;    % Radius of the Earth [m]
d = sqrt( ( Re + h )^2 - Re^2 * sind( theta ).^2 ) - Re * cosd( theta );

end