function delta_f = doppler_shift ( c, v_t, f, theta )

delta_f = + v_t * sind( theta ) / c * f;

end