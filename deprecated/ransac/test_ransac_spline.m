%% Parameters and Functions
s = 4;  % Number of parameters in model
t = 25; % Max distance from model to be an inlier
f_spline = @(x,M) (x(:).^(0:(s-1))*M)';
f_fit = @(X) X(1,:)'.^(0:(s-1))\(X(2,:)');
f_dist = @(M,X,t) deal(find(abs(f_spline(X(1,:),M) - X(2,:)) < t),M);
f_degen = @(x) 0;   % Not degenerate


%% Model ground truth
M = 2*rand(4,1);
x = linspace(-5,5);
y = f_spline(x,M);
X = [x;y];
plot(x,y);

%% Add some noise and outliers
y_noise = y+randn(size(y))*0.25*t;
outliers = rand(size(y))<0.2;
y_noise(outliers) = y_noise(outliers) + randn(size(y_noise(outliers)))*t + randn*10*t;
X_noise = [x;y_noise];
hold on; plot(x(~outliers),y_noise(~outliers),'g.');
plot(x(outliers),y_noise(outliers),'r.'); hold off;

%% Ransac
[Mhat, inliers] = ransac(X_noise,f_fit,f_dist, f_degen, s, t, 0, 100, 1e5);
hold on; plot(x,f_spline(x,Mhat)); hold off;

%% Least Squares
Mls = f_fit(X_noise);
hold on; plot(x, f_spline(x,Mls)); hold off;

%% Decorate
legend('Truth', 'Inliers', 'Outliers', 'RANSAC', 'Least Squares');