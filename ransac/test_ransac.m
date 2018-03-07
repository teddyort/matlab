% Generate data
load pointsForLineFitting.mat
plot(points(:,1),points(:,2),'o');
hold on

%% Least Squares
modelLeastSquares = polyfit(points(:,1),points(:,2),1);
x = [min(points(:,1)) max(points(:,1))];
y = modelLeastSquares(1)*x + modelLeastSquares(2);
plot(x,y,'r-')

%% Ransac Fit
sampleSize = 2; % number of points to sample per trial
maxDistance = 2; % max allowable distance for inliers

fitLineFcn = @(points) polyfit(points(:,1),points(:,2),1); % fit function using polyfit
evalLineFcn = ...   % distance evaluation function
  @(model, points) sum((points(:, 2) - polyval(model, points(:,1))).^2,2);

[modelRANSAC, inlierIdx] = myransac(points,fitLineFcn,evalLineFcn, ...
  sampleSize,maxDistance);
modelInliers = polyfit(points(inlierIdx,1),points(inlierIdx,2),1);

%% Display ransac result
inlierPts = points(inlierIdx,:);
x = [min(inlierPts(:,1)) max(inlierPts(:,1))];
y = modelInliers(1)*x + modelInliers(2);
plot(x, y, 'g-')
legend('Noisy points','Least squares fit','Robust fit');
hold off

%% Calculate the residual in the inliers
ls_res = norm(modelLeastSquares(1)*inlierPts(:,1)+modelLeastSquares(2) - inlierPts(:,2));
rs_res = norm(modelInliers(1)*inlierPts(:,1)+modelInliers(2) - inlierPts(:,2));

disp(['Least Squares Residual: ' num2str(ls_res) ' RANSAC Residual: ' num2str(rs_res)]);