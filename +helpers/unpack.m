function unpack( url, distDir )
% UNPACK Unpack internet archive
%   unpack(url, distDir) Unpack archive defined by 'url' to a 
%     'distDir'. Supports *.tar, *.tar.gz, *.tgz, *.zip
%     archives.
%     For *.gz and *.bz2 archives (formats not supported by Matlab) 
%     needs  wget utility and gunzip + tar utility in the system path.

import helpers.*;

unbzipCommand = 'tar xvjf %s';
unTarGzipCommand = 'tar xvzf %s';
unGzipCommand = 'gunzip %s';
deleteArchive = true;

[address filename ext] = fileparts(url);

switch ext
  case '.gz'
    [d fn ext2] = fileparts(filename);
    if ~strcmp(ext2,'.tar')
      % Handle only gzipped single files
      command = unGzipCommand;
      deleteArchive = false;
    else
      untar(url,distDir);
      return
    end
  case {'.tar','.tgz'}
    untar(url,distDir);
    return;
  case '.zip'
    unzip(url,distDir);
    return;
  case '.bz2'
    command = unbzipCommand;
  otherwise
    error(['Unknown archive extension ' ext]);
end 

% Download the file
archivePath = helpers.downloadFile(url, distDir);

if isempty(archivePath)
  delete(distDir);
  error('Error downloading file from %s.',url); 
end

% Unpack the file
unpackC = sprintf(command,archivePath);

curDir = pwd;
cd(distDir)
try
  status = system(unpackC,'-echo');
  cd(curDir);
catch err
  cd(curDir)
  delete(distDir);
  throw(err);
end

if status ~= 0, error('Error unpacking %s',archivePath); end

% Clean the mess
if deleteArchive
  delete(archivePath);
end

end

