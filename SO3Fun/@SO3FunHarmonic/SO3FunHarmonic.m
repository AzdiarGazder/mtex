classdef SO3FunHarmonic < SO3Fun
% A class representing a harmonic function on the rotational group.

properties
  fhat   = [];              % harmonic coefficients
  SLeft  = specimenSymmetry % symmetry from the left
  SRight = specimenSymmetry % symmetry from the right
  isReal = true
end

properties (Dependent=true)  
  bandwidth   % maximum harmonic degree / bandwidth
  power       % harmonic power
  antipodal
end

methods
 
  function SO3F = SO3FunHarmonic(fhat,varargin)
    % initialize a SO(3)-valued function
    
    if nargin == 0, return;end
    
    % convert arbitrary SO3Fun to SO3FunHarmonic
    if isa(fhat,'SO3Fun')
      SO3F.SRight = fhat.SRight;
      SO3F.SLeft  = fhat.SLeft;
      SO3F.fhat = calcFourier(fhat,varargin{:});
      return
    end
      
    % set fhat
    SO3F.fhat = fhat;
    
    % extract symmetries
    isSym = cellfun(@(x) isa(x,'symmetry'),varargin);
      
    id = find(isSym,2,'first');
    
    if ~isempty(id), SO3F.SRight = varargin{id(1)}; end
    if length(id)>1, SO3F.SLeft = varargin{id(2)}; end
    
    % extend entries to full harmonic degree
    s1 = size(fhat,1);
    if s1>2
      SO3F.fhat(s1+1:deg2dim(dim2deg(s1-1)+2),:)=0;
    end
      
    SO3F.antipodal = check_option(varargin,'antipodal');
    
    % truncate zeros
    A = reshape(SO3F.power,size(SO3F.power,1),prod(size(SO3F)));
    SO3F.bandwidth = find(sum(A,2) > 1e-10,1,'last')-1;
    
  end
     
  function n = numArgumentsFromSubscript(varargin)
    n = 0;
  end
  
  function bandwidth = get.bandwidth(F)
    bandwidth = dim2deg(size(F.fhat,1));
  end
  
  function F = set.bandwidth(F, bw)
    newLength = deg2dim(bw+1);
    s=size(F);
    oldLength = size(F.fhat,1);
     
    if newLength > oldLength % add some zeros
      F.fhat(oldLength+1:newLength,:)=0;
    else % delete zeros
      F.fhat = F.fhat(1:newLength,:);
      F=reshape(F,s);
    end
  end
  
  function pow = get.power(F)
    
    hat = abs(F.fhat).^2;
    pow = zeros([F.bandwidth+1,size(F)]);
    for l = 0:size(pow,1)-1
      pow(l+1,:) = sum(hat(deg2dim(l)+1:deg2dim(l+1),:),1) ./ (2*l+1);
    end
    
  end
    
  function out = get.antipodal(F)      
    if F.CS ~= F.SS
      out = false;
      return
    end
    F=reshape(F,numel(F));
    ind=zeros(deg2dim(F.bandwidth+1),1);
    for l = 0:F.bandwidth
      localind = reshape(deg2dim(l+1):-1:deg2dim(l)+1,2*l+1,2*l+1)';
      ind(deg2dim(l)+1:deg2dim(l+1))=localind(:);
    end
    dd = sum(abs(F.fhat-F.fhat(ind,:)).^2);
    out = prod(sqrt(dd) ./ norm(F)' <1e-4);
  end
  
  function F = set.antipodal(F,value)
    if ~value, return; end
    if F.CS ~= F.SS
      error('ODF can only be antipodal if both crystal symmetry coincide!')
    end
    s=size(F);
    F=reshape(F,prod(s));
    ind=zeros(deg2dim(F.bandwidth+1),1);
    for l = 0:F.bandwidth
      localind = reshape(deg2dim(l+1):-1:deg2dim(l)+1,2*l+1,2*l+1)';
      ind(deg2dim(l)+1:deg2dim(l+1))=localind(:);
    end
    F.fhat = 0.5*(F.fhat+F.fhat(ind,:));
    F=reshape(F,s);
  end
  
%   function F = get.isReal(F)
%     % test whether fhat is symmetric fhat_nkl = conj(fhat_n-k-l)
%   end
  % DO WE NEED function F = set.isReal(F,value)
  
  function d = size(F, varargin)
    d = size(F.fhat);
    d = d(2:end);
    if length(d) == 1, d = [d 1]; end
    if nargin > 1, d = d(varargin{1}); end
  end
  
  function n = numel(F)
    n = prod(size(F)); %#ok<PSIZE>
  end
  
end

methods (Static = true)
  %sF = approximation(v, y, varargin);
  %SO3F = quadrature(f, varargin);
  %sF = regularisation(nodes,y,lambda,varargin);
  SO3F = WignerDmap(harmonicdegree,varargin);
end

end
