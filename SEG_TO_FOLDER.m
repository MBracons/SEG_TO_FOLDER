% Program: <SEG_TO_FOLDER.m>
% Author: Marc Bracons Cucó
% Affiliation: Department of Telecommunication and Systems Engineering, Autonomous University of Barcelona, Wireless Information Networking Group
% Copyright © 2023 Marc Bracons Cucó
%
% This program is proprietary software; you may not use, distribute, or modify it 
% without the explicit permission of the author.
%
% If you wish to use this program in your work, please, contact the author.

% Script que usa el archivo de segment seg.mat para obtener la region de
% interes, se usa para obtener los desplazamientos por paciente

% Cambiar el número de paciente y los valores de A y B aquí:
num_paciente = '107';
B = 45; % desplazamiento vertical
A = 67; % desplazamiento horizontal

clc
close all
cd(['/home/win001/00_heart/00_Dataset_CNN/00_Dataset_Rename/Amiloidosis/_' num_paciente])
load('seg.mat');

EpiX = SEG.EpiX;
EpiY = SEG.EpiY;
EpiX_2D = squeeze(EpiX);
EpiY_2D = squeeze(EpiY);

% Reemplazar los valores NaN por 0
EpiX_2D_normalized = EpiX_2D;
EpiX_2D_normalized(isnan(EpiX_2D_normalized)) = 0;

EpiY_2D_normalized = EpiY_2D;
EpiY_2D_normalized(isnan(EpiY_2D_normalized)) = 0;

% Cerrar la curva
se = strel('disk', 10);

% Obtener los nombres de archivo de la carpeta
files = dir('*.png');
file_names = {files.name};

% Filtrar los nombres de archivo que empiezan con el número de paciente
idx = startsWith(file_names, num_paciente);
file_names = file_names(idx);

% Convertir las partes numéricas de los nombres de archivo en valores numéricos
%file_nums = cellfun(@(x) str2num(x(5:end-4)), file_names);
file_nums = cellfun(@(x) str2num(x(find(x=='_',1,'last')+1:end-4)), file_names);

% Ordenar los nombres de archivo según los valores numéricos en orden inverso
[~, sort_idx] = sort(file_nums, 'descend');
file_names = file_names(sort_idx);

num_files = length(file_names);

for i = 1:num_files
    % Cargar la imagen en orden inverso
    filename = file_names{i};
    img = imread(filename);

    % Desplazar los puntos A píxeles a la derecha
    EpiY_2D_normalized(:,i) = EpiY_2D_normalized(:,i) + A;

    % Desplazar los puntos B píxeles hacia abajo
    EpiX_2D_normalized(:,i) = EpiX_2D_normalized(:,i) + B;

    % Expandir la zona
    EpiBW = poly2mask(EpiY_2D_normalized(:,i), EpiX_2D_normalized(:,i), size(img,1), size(img,2));
    EpiClosed = imclose(EpiBW, se);
    C = 5; % Número de píxeles a expandir
    EpiDilated = imdilate(EpiClosed, strel('disk', C));

    % Mostrar la imagen y la zona expandida en rojo
    figure(i)
    imshow(img);
    hold on;
    [C,L] = bwboundaries(EpiDilated, 'noholes');
    for k = 1:length(C)
        boundary = C{k};
        plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1);
    end
    
    % Establecer los límites del eje para ajustarse a los datos en la imagen y recortar cualquier borde blanco
    axis tight;
    
    % Esperar hasta que la imagen y la zona expandida se hayan dibujado completamente antes de pasar a la siguiente iteración
    drawnow;
    waitfor(gcf);
end
 

