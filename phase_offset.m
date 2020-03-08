function phi = phase_offset ( k0, d_elem, K, theta0, elem, theta )

phi = k0 * ( K - elem ) * d_elem * ( sind( theta ) - sind( theta0 ) );

end