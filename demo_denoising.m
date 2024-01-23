% 纪定一
% 共聚焦非视域成像 扫描获得高噪声三维数据 BM4D去噪

%
% 代码基于 http://www.cs.tut.fi/~foi/GCF-BM3D的相关工作修改
% 数据来源于文章 Learned Feature Embeddings for Non-Line-of-Sight Imaging and Recognition


clear all;close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modifiable parameters
sigma             = 11;      % noise standard deviation given as percentage of the
                             % maximum intensity of the signal, must be in [0,100]
distribution      = 'Gauss'; % noise distribution
                             %  'Gauss' --> Gaussian distribution
                             %  'Rice ' --> Rician Distribution
profile           = 'mp';    % BM4D parameter profile
                             %  'lc' --> low complexity
                             %  'np' --> normal profile
                             %  'mp' --> modified profile
                             % The modified profile is default in BM4D. For 
                             % details refer to the 2013 TIP paper.
do_wiener         = 1;       % Wiener filtering
                             %  1 --> enable Wiener filtering
                             %  0 --> disable Wiener filtering
verbose           = 1;       % verbose mode

estimate_sigma    = 0;       % enable sigma estimation

% phantom           = 't1_icbm_normal_1mm_pn0_rf0.rawb'; % name of the phantom raw data
crop_phantom      = 1;       % experiment on smaller phantom
save_mat          = 0;       % save result to matlab .mat file
variable_noise    = 0;       % enable spatially varying noise
noise_factor      = 3;       % spatially varying noise range: [sigma, noise_factor*sigma]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MODIFY BELOW THIS POINT ONLY IF YOU KNOW WHAT YOU ARE DOING       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check parameters
if sigma<=0
	error('Invalid "sigma" parameter: sigma must be greater than zero');
end
if noise_factor<=0
    error('Invalid "noise_factor" parameter: noise_factor must be greater than zero.');
end
estimate_sigma = estimate_sigma>0 || variable_noise>0;

% % read original phantom
% if ~exist(phantom,'file')
%     error(['Could not read phantom "',phantom,'" file. You can download ',...
%         'BranWeb phantom from http://brainweb.bic.mni.mcgill.ca/'...
%         'brainweb/selection_normal.html (Modality T1, Slice thickness 1mm, ',...
%         'Noise 0%, Intensity non-uniformity 0%) with format raw byte (unsigned)']);
% end


%原先的数据加载的代码
% fid = fopen(phantom);
% y = reshape(fread(fid,181*217*181),[181 217 181])/255;
% fclose(fid);
% if crop_phantom
%     y = y(51:125,51:125,51:125);
% end
%现在的数据加载代码
%y = load("bike0.mat","measlr");
y = load("statue0.mat","measlr");

y = y.measlr;
y = y(22:230,22:230,120:end);


% generate noisy phantom
randn('seed',0);
rand('seed',0);
sigma = sigma/100;
if variable_noise==1
    disp(['Spatially-varying ',distribution,' noise in the range [',...
        num2str(sigma),',',num2str(noise_factor*sigma),']'])
    map = helper.getNoiseMap(y,noise_factor);
else
    disp(['Uniform ',distribution,' noise ',num2str(sigma)])
    map = ones(size(y));
end
eta = sigma*map;
if strcmpi(distribution,'Rice')
    z = sqrt( (y+eta.*randn(size(y))).^2 + (eta.*randn(size(y))).^2 );
else
    z = y + eta.*randn(size(y));
end

% perform filtering
disp('Denoising started')
% [y_est, sigma_est] = bm4d(z, distribution, (~estimate_sigma)*sigma, profile, do_wiener, verbose);
% 这个地方我们把噪声sigma设为0，让它自动估计自动去估计
[y_est, sigma_est] = bm4d(z, distribution, 0, profile, do_wiener, verbose);


% objective result
ind = y>0;
PSNR = 10*log10(1/mean((y(ind)-y_est(ind)).^2));
SSIM = ssim_index3d(y*255,y_est*255,[1 1 1],ind);
fprintf('Denoising completed: PSNR %.2fdB / SSIM %.2f \n', PSNR, SSIM)

% plot historgram of the estimated standard deviation
if estimate_sigma
    helper.visualizeEstMap( y, sigma_est, eta );
end

% show cross-sections 我先把这里打掉了
%helper.visualizeXsect( y, z, y_est );

% save experiments workspace
if save_mat
    save([phantom,'_sigma',num2str(sigma*100),'.mat'],...
        'y','z','y_est','sigma_est','sigma','PSNR')
end
