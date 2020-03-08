function Pl = free_space_path_loss (d0, d)

Pl = - 20 * log10( d0 ./ d );    % Free space path loss [dB]

end