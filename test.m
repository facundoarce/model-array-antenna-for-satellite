%% Parameters
clc, clear, close all
c = 3e8;                    % Propagation speed in free space [m/s]
f = 150e6;                  % Frequency of radiation [Hz = 1/s]
lambda0 = c / f;            % Wavelenght [m]
k0 = 2 * pi / lambda0;      % Free space wave number
d = lambda0 / 2;            % Distance between radiators/elements [m]
K = 4;                      % Number of radiators/elements in array

%% Radiation patterns
% Grating lobes within visible space (-90 <= theta <= 90)
if d/lambda0 <= 1
    fprintf('No visible grating lobes\nd/lambda0 = %f <= 1\n', d/lambda0)
else
    fprintf('Visible grating lobes\nd/lambda0 = %f > 1\n', d/lambda0)
end

s_a = [];   % Array factor
s_e = [];   % Element factor
s = [];     % Total array radiation pattern
th = [];

for theta = -90 : 90
    th = [th, theta];
    s_a = [s_a, normalized_array_factor(array_factor( k0, d, K, theta ), K )];
    s_e = [s_e, normalized_element_factor( element_factor( theta ) )];
    s = [s, radiation_pattern(k0, d, K, theta)];
end

figure()
plot(th, s_a, th, s_e, th, s);
xlim([-90 90])
ylim([-60 0])
legend('Array factor','Element factor', 'Total array')
xlabel('Angle relative to broadside [deg]')
ylabel('Power radiation pattern [dB]')
title('Radiation pattern')

%% Phase offset due to antenna array
T = 1e-8;
dt = 1e-10;
time = 0 : dt : T;
s_i = zeros(K, length(time));
theta = 45;
counter = 0;

figure()
for elem = 1 : K
    for t = 0 : dt : T
        counter = counter + 1;
        s_i(elem, counter) = received_signal( f, k0, d, K, elem, theta, t );
    end
    plot(time, s_i(elem,:));
    hold on;
    
    counter = 0;
end

legend('Element 1','Element 2', 'Element 3', 'Element 4')
xlabel('Time [s]')
ylabel('Relative amplitude')
title('Received signal')

%% Frequency shift due to doppler effect
v_t = 7700;     %% tangential speed of satellite [m/s] 
th = [];
delta_f = [];

for theta = -90 : 90
    th = [th, theta];
    delta_f = [delta_f, - v_t * sind( theta ) / c * f];
end
f_obs = f + delta_f;

figure()
plot(th, delta_f);
grid on
xlim([-90 90])
xlabel('Angle relative to broadside [deg]')
ylabel('Doppler shift [Hz]')
title('Doppler shift')

figure()
plot(th, f_obs);
grid on
xlim([-90 90])
xlabel('Angle relative to broadside [deg]')
ylabel('Observed frequency [Hz]')
title('Received signal')

%% Amplitude offsett due to free-space path loss
h = 500e3;                              % Flying altitude [m] 
d = h;                                  % Distance between the satellite and the ground station
Pl = free_space_path_loss( h, 700e3 );  % Free-space path loss relative to zenith [dB]
Pr = 10^(-Pl/10);                       % Relative received power [0;1]
% Vr = 10^(-Pl/10);                       % Relative voltage [0;1]

th = [];
dist = [];
pl = [];
pr = [];

for theta = -90 : 90
    th = [th, theta];
    d = distance_to_satellite( h, theta );
    Pl = free_space_path_loss( h, d );
    
    dist = [dist, d];
    pl = [pl, Pl];
    pr = [pr, 10^(-Pl/10)];
end
R = 50;
Vr = sqrt(pr*R);
figure()
subplot(3,1,1)
plot(th, dist);
grid on
xlim([-90 90])
xlabel('Angle relative to broadside [deg]')
ylabel('Distance [m]')
title('Distance from antenna to satellite')

subplot(3,1,2)
plot(th, pl);
grid on
xlim([-90 90])
xlabel('Angle relative to broadside [deg]')
ylabel('Power loss [dB]')
title('Free-space path loss relative to zenith')

subplot(3,1,3)
plot(th, pr);
grid on
xlim([-90 90])
xlabel('Angle relative to broadside [deg]')
ylabel('Power [-]')
title('Received power relative to zenith')

figure
plot(th, Vr/max(Vr));
hold on
plot(th, sqrt(pr), 'r');


