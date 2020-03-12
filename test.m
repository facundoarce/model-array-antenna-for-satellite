%% Parameters
clc, clear, close all
c = 3e8;                    % Propagation speed in free space [m/s]
f0 = 150e6;                 % Frequency of radiation [Hz = 1/s]
lambda0 = c / f0;           % Wavelenght [m]
k0 = 360 / lambda0;         % Free space wave number [\circ/m] 2 * pi / lambda0;
d_elem = lambda0 / 2;       % Distance between radiators/elements [m]
K = 4;                      % Number of radiators/elements in array
h = 650e3;                  % Flying altitude [m] 
theta = -90 : 90;           % Angle relative to broadside
theta0 = -20;                 % Desired beam-pointing direction [\circ]

%% Satellite motion
% Supposing a uniform circular motion that 
Re = 6371e3;                % Radius of the Earth [m]
Me = 5.98e24;               % Mass of the Earth [kg]
G = 6.673e-11;              % Gravitational constant [N*m^2/kg^2]
R = Re + h;                 % Radius of the satellite trajectory [m]

v_t = sqrt( G * Me / R );   % Tangential velocity of satellite [m/s] 
w = v_t / R * 180 / pi;     % Angular velocity [\circ/s]

% d_max = distance_to_satellite_antenna (h, -90);
% alpha_max = 2 * asind( d_max * sind(90) / ( Re + h ) );
alpha_max = 2 * acosd( Re / R );
t_end = ceil(alpha_max / w);

d_max = distance_to_satellite_earth(h, alpha_max, 0);
T = 360 / w / 60;           % Period [min]

t = 0 : t_end;
alpha = w * t;

d_t = distance_to_satellite_earth ( h, alpha_max, alpha );
theta_t = alpha_to_theta ( h, d_t, alpha_max, alpha );

figure()
plot(t/60, alpha, t/60, theta_t, 'LineWidth', 2)
grid on
set(gca,'ytick',[-90:30:90])
legend('\alpha (referencia de la Tierra)', '\theta (referencia de la antena)')
xlabel('Tiempo [min]')
ylabel('Ángulo [\circ]')
title('Trayectoria angular del satélite')
save_figure('angular-trajectory-satellite');

figure()
plot(t/60, d_t/1000, 'LineWidth', 2)
grid on
xlabel('Tiempo [min]')
ylabel('Distancia [km]')
title('Distancia de la antena al satélite')
save_figure('t-distance-antenna-satellite');

%% Radiation patterns
% Grating lobes within visible space (-90 <= theta <= 90)
if d_elem/lambda0 <= 1/2     % 1 for broadside linear array (theta0=0) and 1/2 for phased array
    fprintf('No visible grating lobes\nd/lambda0 = %f <= 1/2\n', d_elem/lambda0)
else
    fprintf('Visible grating lobes\nd/lambda0 = %f > 1/2\n', d_elem/lambda0)
end

s_a = array_factor( k0, d_elem, K, theta0, theta );  % Array factor
s_a_n = normalized_array_factor( s_a, K );

s_e = element_factor( theta );                  % Element factor
s_e_n = normalized_element_factor( s_e );

s = radiation_pattern (s_a, s_e, K);            % Total array radiation pattern

figure()
plot(theta, s_a_n, theta, s_e_n, theta, s, 'LineWidth', 2);
grid
xlim([-90 90])
ylim([-60 0])
set(gca,'xtick',[-90:10:90])
legend('Factor de arreglo','Factor de elemento', 'Patrón resultante')
xlabel('\theta [\circ]')
ylabel('Patrón de radiación [dB]')
title('Patrón de radiación')
save_figure('radiation-pattern');

%% Phase offset due to antenna array
elem = ( 1 : K )';
phi = phase_offset ( k0, d_elem, K, theta0, elem, theta );	% phase offset

figure()
plot(theta, phi(1,:), theta, phi(2,:), theta, phi(3,:), theta, phi(4,:), 'LineWidth', 2);
grid
xlim([-90 90])
set(gca,'xtick',[-90:10:90])
set(gca,'ytick',[-540:90:540])
legend('Elemento 1','Elemento 2', 'Elemento 3', 'Elemento 4', 'Location', 'northwest')
xlabel('\theta [\circ]')
ylabel('Desfasaje [\circ]')
title('Diferencia de fase')
save_figure('phase-offset')

% % PARA POSTER
% figure()
% plot(theta, phi(1,:), theta, phi(2,:), theta, phi(3,:), theta, phi(4,:), 'LineWidth', 2);
% grid
% xlim([-90 90])
% set(gca,'xtick',[-90:30:90])
% set(gca,'ytick',[-540:180:540])
% legend('Element 1','Element 2', 'Element 3', 'Element 4')
% xlabel('Angle relative to broadside [\circ]')
% ylabel('Phase offset [\circ]')
% title('Phase offset')
% set(gcf, 'Position', [100, 100, 375, 175])

%% Frequency shift due to doppler effect
delta_f = doppler_shift ( c, v_t, f0, theta );
f_obs = f0 + delta_f;

figure()
plot(theta, delta_f, 'LineWidth', 2);
grid on
xlim([-90 90])
set(gca,'xtick',[-90:10:90])
xlabel('\theta [\circ]')
ylabel('Corrimiento por Doppler [Hz]')
title('Diferencia de frecuencia')
save_figure('doppler-shift')

% % PARA POSTER
% figure()
% plot(theta, delta_f, 'LineWidth', 2);
% grid on
% xlim([-90 90])
% set(gca,'xtick',[-90:30:90])
% xlabel('Angle relative to broadside [\circ]')
% ylabel('Doppler shift [Hz]')
% title('Doppler shift')
% set(gcf, 'Position', [100, 100, 350, 175])

figure()
plot(theta(1:end-1), diff(delta_f), 'LineWidth', 2);
grid on
xlim([-90 90])
set(gca,'xtick',[-90:10:90])
xlabel('\theta [\circ]')
ylabel('Tasa de corrimiento por Doppler [Hz/\circ]')
title('Tasa de corrimiento por Doppler')
save_figure('doppler-shift-derivative')

figure()
plot(theta, f_obs/1e6, 'LineWidth', 2);
grid on
xlim([-90 90])
set(gca,'xtick',[-90:10:90])
xlabel('\theta [\circ]')
ylabel('Frecuencia observada [MHz]')
title('Frecuencia observada')
save_figure('observed-frequency')

%% Amplitude offsett due to free-space path loss
d = distance_to_satellite_antenna( h, theta );  % Distance between the satellite and the ground station
Pl = free_space_path_loss( h, d );              % Free-space path loss relative to zenith [dB]
Pr = 10.^(-Pl/10);                              % Relative received power [0;1]
Vr = sqrt(Pr);                                  % Relative voltage [0;1] (P=V^2/R) 

figure()
plot(theta, d, 'LineWidth', 2);
grid on
xlim([-90 90])
set(gca,'xtick',[-90:10:90])
xlabel('\theta [\circ]')
ylabel('Distancia [m]')
title('Distancia de la antena al satélite')
save_figure('distance-antenna-satellite')

figure()
plot(theta, Pl, 'LineWidth', 2);
grid on
xlim([-90 90])
set(gca,'xtick',[-90:10:90])
xlabel('\theta [\circ]')
ylabel('Pérdidas relativas [dB]')
title('Pérdidas por trayectoria en espacio libre')
save_figure('free-space-path-loss')

% % PARA POSTER
% color = [0.4660, 0.6740, 0.1880];
% figure()
% plot(theta, Pl, 'LineWidth', 2, 'Color', color);
% grid on
% xlim([-90 90])
% set(gca,'xtick',[-90:30:90])
% xlabel('Angle relative to broadside [\circ]')
% ylabel('Power loss [dB]')
% title('Normalized free-space path loss')
% set(gcf, 'Position', [100, 100, 350, 175])

figure()
plot(theta, Pr, 'LineWidth', 2);
grid on
xlim([-90 90])
set(gca,'xtick',[-90:10:90])
xlabel('\theta [\circ]')
ylabel('Potencia [-]')
title('Potencia recibida relativa')
save_figure('received-power')

figure()
plot(theta, Vr, 'LineWidth', 2);
grid on
xlim([-90 90])
set(gca,'xtick',[-90:10:90])
xlabel('\theta [\circ]')
ylabel('Voltaje [-]')
title('Voltaje recibido relativo')
save_figure('voltage-received')

%% BEAM FORMING WITH CABLES OF DIFFERENT LENGTH
delta_d_cable = 227e-3;                 % Length difference between cables
v_cable = 0.66 * c;                     % Propagation speed in the cable [m/s]
t_dif = delta_d_cable / (0.66*c);       % Time offset between signals [s]
phase_shift = -360 * t_dif / (1/f0)      % Phase shift of signals [\circ]

[ ~, ix ] = min( abs( phi(3,:) - phase_shift ) );
theta_beam = theta(ix)                  % Beam-pointing direction [\circ]

%% Received signals as a function of time
% Frequency
delta_f = doppler_shift ( c, v_t, f0, theta_t );
% Phase
elem = ( 1 : K )';
phi = phase_offset ( k0, d_elem, K, theta0, elem, theta_t );
% Amplitude
Pl = free_space_path_loss( h, d_t );    % Free-space path loss relative to zenith [dB]
Pr = 10.^(-Pl/10);                      % Relative received power [0;1]
Vr = sqrt(Pr);                          % Relative voltage [0;1] (P=V^2/R) 
% Vr = h/d

figure()
plot(t/60, delta_f/1e3, 'LineWidth', 2);
grid on
xlabel('Tiempo [min]')
ylabel('Corrimiento de frecuencia [kHz]')
% title('Received signal')
save_figure('t-frequency-shift')

figure()
plot(t/60, phi(1,:), t/60, phi(2,:), t/60, phi(3,:), t/60, phi(4,:), 'LineWidth', 2);
legend('Elemento 1','Elemento 2', 'Elemento 3', 'Elemento 4')
grid on
set(gca,'ytick',[-540:180:540])
xlabel('Tiempo [min]')
ylabel('Desfasaje [\circ]')
% title('Received signal')
save_figure('t-phase-offset')

figure()
% color = [0.4660, 0.6740, 0.1880];
plot(t/60, Pr, 'LineWidth', 2);
grid on
xlabel('Tiempo [min]')
ylabel('Amplitud relativa')
% title('Received signal')
save_figure('t-relative-amplitude')


