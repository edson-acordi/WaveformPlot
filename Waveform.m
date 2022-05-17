# Script para gerar/plotar uma Forma de onda Customizável + Espectro harmônico.
# Para usar a função noise() é necessário instalar o pacote ltfat:
# Configurar o editor com text encoding ISO-8859-1
# pkg install -forge ltfat
# By.: Edson Junior Acordi
# Data: 05/06/2020

# Limpa o workspace
clear all;
clc;

# Ajusta o formato dos números
format long;  # formato longo

# ------------------------------------------------------------------------------
# Gráfico de uma função periódica, por exemplo, tensão de alimentação.
# Obs.: o número de pontos deve ser >= a 100 para uma boa visualização quando
# o sinal da tensão conter apenas a frequência fundamental.
# Quando conter harmônicas, o número de pontos deve ser aumentado.
f = 60; # Frequência fundamental (Hz)
w = 2*pi*f; # Frequência angular (rad/s)

np = 200; # Número de pontos/ciclo da forma de onda da função y (tensão de alim.)
n = np*f; # Intervalo de incremento da forma de onda em função da frequência
N = 2;  # Número de ciclos
fa = (f*np); # Calcula a frequência de amostragem em função de f e n

#-------------------------------------------------------------------------------
# ==== Vetor de Tempo ====
# Obs.: Escolher uma das opções:
#       se deseja o número de pontos/ciclo;
#       ou o número de pontos da forma de onda.

# A última amostra deve descontar um ponto de incremento para que o número de
# pontos seja igual ao valor desejado em np.
ua = (1/f)*N - 1/n;  % Desconta o Incremento de 1/n

# Especifica o Número de pontos por ciclo
x = 0 : 1/(n) : ua;  # Intervalo: 0 a ua, 1/n incremento dos pontos

# Especifica o Número de pontos da forma de onda (total)
# x = 0 : 1/(n/N) : (1/60)*N;  # Intervalo e incremento dos pontos para o gráfico
#-------------------------------------------------------------------------------

# Adiciona harmônicos na forma de onda
hterm = 0*(1/10)*sin(2*x*w) + 1*(1/1)*sin(3*x*w) + 0*(1/10)*sin(5*x*w) + ...
        0*(1/7)*sin(7*x*w) + 0*(1/9)*sin(9*x*w) + 0*(1/11)*sin(11*x*w) + ...
        0*(1/13)*sin(13*x*w); #+ ...
##        0*(1/15)*sin(15*x*w) + 0*(1/17)*sin(17*x*w) + 0*(1/19)*sin(19*x*w) + ...
##        0*(1/21)*sin(21*x*w) + 0*(1/23)*sin(23*x*w) + 0*(1/25)*sin(25*x*w) + ...
##        0*(1/50)*sin(50*x*w)+...
##        0*(1/48)*0*sin(48*x*w)+0*(1/51)*sin(51*x*w);

Vp = 311; # Grandeza do gráfico (ex.: tensão)

#-------------------------------------------------------------------------------
# == Gera sinal de Ruído aleatório com percentual de Vp para ser adicionado ==
# a tensão de alim.
# Obs.: O valor médio é diferente de zero

#ruido = 0.15*Vp*randn(size(x));  # Randômico

# == Gera sinal de Ruído Branco com percentual de Vp ==
# Obs 1.: Ruído branco apresenta potência distribuída uniformemente no espectro
# de frequência. É constituído de um sinal aleatório com intensidade igual em
# diferentes frequências, logo, possui densidade espectral de potência
# constante.
# Obs 2.: O ruído branco possui distribuição Gaussiana, o que resulta em um
# valor médio nulo (ruído com outros tipos de distribuição são artificialmente
# produzidos)
# Carrega o pacote ltfat
pkg load ltfat; # Usado para gerar ruído branco
ruido = 0.5*Vp*noise(N*np, 'white'); # White noise
ruido = ruido'; # Adequa o vetor ruido para vetor linha (transposta)
#-------------------------------------------------------------------------------

V0 = 0; %50.12345;  # Valor CC do sinal

# Forma de onda
fi = 0; #3*pi/2;  # Fase do sinal
y = 1*V0 + Vp*sin(x*w+fi) + 1*Vp*hterm + 0*ruido;

% Ajustas o tamanho da Janela da Figura em Pixels
width = 600;#350; # Largura da janela
height = 300;#200; # Altura da janela
posx = 420; # Posição X inicial da janela em pixels
posy = 200; # Posição Y inicial da janela em pixels

# Cria uma Janela para plotar o gráfico do sinal
hf = figure('position',[posx, posy ,width, height]);

# Marcação no sinal amostrado
marc = 0;
if marc == 1
mark = 'o'; # Tipo do marcador
plot(x, y, "linewidth", 0.5, "color", [0 0 1], mark,...
    'MarkerEdgeColor',[0 0.5 0],...
    'MarkerFaceColor',[1 1.0 1],...
    'MarkerSize', 5);
endif

# Gráfico da forma de onda
hold on;
plot(x, y, "linewidth", 0.5, "color", [0 0 1]); # Contorno do sinal amostrado

# Gráfico em barras da forma de onda (sinal amostrado)
# Obs.: Plota na mesma Figura do sinal
barra = 0;
if barra == 1
barw = 0.15; # Largura das barras
bar(x, y, barw, "facecolor", "blue", "edgecolor", [0 0.5 1]); 
endif

limits = axis; # Para uso do posicionamento automático do texto conforme escala
yl = limits(3); # Extrai o valor mínimo no eixo Y
yh = limits(4); # Extrai o valor máximo no eixo Y

# Mostra texto na posição x, y no gráfico
text(1/(2.5*60), yh+50, ['Freq. Amostragem: ', num2str(fa), ' Hz']);

xlim ([0, N*(1/f)]);  # Ajusta os limites em X
ylim ([yl-100, yh+100]);  # Ajusta os limites em Y

grid on; # Mostra o grid
xlabel ('Tempo (ms)'); # Nome no eixo x
ylabel ('Amplitude (V)'); # Nome no eixo y
title ('Forma de Onda Customizável', ...
"interpreter", "latex");

##legend ("f"); # Legenda

grid on;
box on;

#-------------------------------------------------------------------------------
# Ajusta o espaçamento das marcas em X - em rad
##xlim ([0.00, (1/60)+2*(1/720)]);  # Ajusta os limites em Y
##ylim ([450.00, 540.00]);  # Ajusta os limites em Y

##set(gca,'XTick', [0 : (1/720) : (1/f)+2*(1/720)]);

# Ajusta os labels das marcas em X manualmente
##set(gca, "xticklabel", {'0', '\pi/6', '', '\pi/2', '', '5\pi/6', '', ...
##'7\pi/6', '', '3\pi/2', '', '11\pi/6', '', '13\pi/6', ''});
#-------------------------------------------------------------------------------

# Mostra as marcas MinorTick em X e Y 
set(gca,'XMinorTick','on','YMinorTick','on');

#-------------------------------------------------------------------------------
# Ajusta o espaçamento das marcas em X - tempo ms
set(gca,'XTick', [0 : 0.002 : (1/f)*N]);  # Configurado para 1 ciclo de 60Hz

# Ajusta os labels das marcas em X manualmente em milisegundos
set(gca, "xticklabel", {'0', '2', '4', '6', '8', '10', '12', '14', '16'});
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# == Gera arquivo com a Figura da forma de onda ==

# Ajusta o tamanho e o tipo da fonte dos eixos X e Y
set(gca, 'FontName', 'times', "fontweight", "normal", 'fontsize', 12);

#print('teste.svg', '-dsvg', '-S350,200', '-FCambriaMath:4');
#print('teste.svg', '-dsvg', '-S350,200');
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# == Plota a versão Amostrada do Sinal ==
figure();
stem(y);  # Plota as amostras do sinal
hold on;
plot(y);  # Contorno do sinal
title('Sinal Amostrado');
xlabel('Número da Amostra');
ylabel('Amplitude');
grid on;
box on;
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# ==== Espectro do Sinal - FFT ====
pkg load signal;  # Carrega o pacote signal
comp = length(y); # Comprimento do vetor do sinal (número de amostras)
aux = 0 : 1/N : comp-1; # 
T = (comp/fa)/N;  # Período do sinal
fx = (aux/T); # Gera o vetor das abscissa (X) com o valor das frequências
fft_signal = fftn(y)/(comp);  # Calcula a FFT do sinal e escalona os elementos
fc = ceil(comp/(2)); # Frequência de corte (elimina a imagem espelhada do espectro)
#fft_signal = fft_signal(1:fc); # Ajusta a FFT da fundamental até fc

# Extrai a amplitude (1/2 do valor de pico) da componente de freq. fundamental 
# fft_signal(1) -> componente CC
# fft_signal(2) -> primeira frequência (depende do número de ciclos N)
# fft_signal(3) -> segunda frequência (depende do número de ciclos N)
# fft_signal(4) -> terceira frequência (depende do número de ciclos N)
# fft_signal(n) -> enésima frequência (depende do número de ciclos N)
# Notar que o número do elemento harmônico fft_signal(n) não tem correspondência
# com a ordem do harmônico para n>2.

# Magnitude da componente CC e 1/2 da complemente fundamental
# Obs.:
# real(fft_signal(n)) -> Extrai a parte real da componente n da FFT do sinal
# imag(fft_signal(n)) -> Extrai a parte imaginária da componente n da FFT do sinal
# abs(fft_signal(n)) -> Calcula a amplitude do sinal
Vcc = abs(fft_signal(1)); # Amplitude da componente CC do sinal
Vp1 = abs(fft_signal(1+N)); # 1/2 da Amplitude de pico da freq. fundamental

#----------------------------------------------------------
% Scale every point except first and last properly,
% The 2 is because we use only 1/2 the calculated spectrum,
% The sqrt(2) converts properly to RMS values.
#y(2:end-1) = (2 / sqrt(2)) * y(2:end-1);

# Seleciona a amplitude desejada para o espectro
# amp = 1, valor normalizado (fundamental = 100%)
# amp = 2, valor eficaz
amp = 1;  # Escolher 1 ou 2

if amp == 1 # FFT com valor normalizado no pico da fundamental
  # Ajusta a FFT da fundamental até fc 
  fft_signal_out = (fft_signal(1:fc)/Vp1)*100; # Valor normalizado
endif

if amp == 2 # FFT com valor eficaz
    # Ajusta a FFT da fundamental até fc
  fft_signal_out = fft_signal(1:fc); #
  fft_signal_out(2:end) = (2 / sqrt(2)) * fft_signal_out(2:end);  # Valor eficaz
endif

# Ajustes para plotar o Espectro Harmônico tradicional ou em barras
h = 60; # Se 1, eixo X=frequência, se 60, eixo X = ordem harmônica (não comentar)
fx = fx/h; # Converte o Eixo X para ordem harmônica se h=60

# Ajuste da Janela da Figura do Espectro Harmônico
width = 500; # Largura da janela
figure('position',[posx, posy, width, height]); # Cria uma Janela para plotar o gráfico

# ---- Espectro Harmônico tradicional ----
#plot(fx(1:fc),abs(fft_signal_out));

# ---- Espectro Harmônico no formato de Barras ----
bw = 0.50; # Largura das barras
ini = 2; # Primeira barra do espectro a ser mostrada (1 = componente CC)
         # (2 = primeira frequência), etc...

#-------------------------------------------------------------------------------
# == Permite ajustar a cor da componente fundamental ==
# Para usar, ajustar ini = 3 (para 1 ciclo).
# Para plotar somente as harmônicas, comentar a linha abaixo e ajustar ini=3
##bar(fx(1+N),abs(fft_signal_out(1+N)), bw/(2*N), "facecolor", [0 0.5 0],...
##    "edgecolor", [0 0.5 0]); # Espectro da componente fundamental (ajuste da cor)
##xlim([0.75, 60*51.25/h]);  # Ajusta os limites em X. Comentar se não for ajustar
                           # a cor da componente fundamental (linha 230-231)
#-------------------------------------------------------------------------------

xlim([ini-1.25, 60*51.25/h]);  # Ajusta os limites em X
ylim([0, 100]);  # Ajusta os limites em X

hold on;
bar(fx(ini:fc),abs(fft_signal_out(ini:end)), bw, "facecolor", "blue",...
    "edgecolor", "blue"); # Espectro das componentes harmônicas

title('Analisador de Espectro Unilateral');
ylabel('Amplitude (% da fundamental)');
#ylabel('Amplitude (valor RMS)');
grid on;

box on;

# Mostra valor CC do sinal e eficaz da componente fundamental
text(23, 94, ['Valor CC do sinal = ', num2str(sprintf('%.2f',Vcc)), ' V'],...
     'fontsize', 10);
text(23, 83, ['Valor RMS de f_1 = ', num2str(sprintf('%.2f', Vp1*2/sqrt(2))),...
    ' V'], 'fontsize', 10);

#-------------------------------------------------------------------------------
# ==== Calcula a Distorção Harmônica Total do sinal ====
# Vetor com metade do espectro do sinal e sem a Componente CC e a Fundamental
fft_signal_DHT = fft_signal(2+N:fc);

# Calcula o valor eficaz de cada elemento harmônico da FFT
fft_signal_DHT = (2 / sqrt(2)) * fft_signal_DHT;

Vhrms = abs(fft_signal_DHT);  # Módulo da FFT com os valores eficazes das harmo.
V1rms = 2*Vp1/sqrt(2);  # Valor eficaz da componente fundamental
DHT = (sqrt(sum(Vhrms.^2))/V1rms)*100;  # Distorção Harmônica Total em %

text(23, 74, ['DHT = ', num2str(sprintf('%.2f', DHT)),...
    ' %'], 'fontsize', 10); # Mostra o valor da DHT no gráfico do espectro
#-------------------------------------------------------------------------------

# Seta para indicar que a fundamental é de 100%. Utilizar quando o limite em Y
# for ajustado para valores menores que 100%
annotation('arrow', [0.13355 0.13355], [0.89 0.9285], 'HeadWidth', 2.5,...
           'HeadStyle', 'vback2', 'HeadLength', 2.5, 'LineWidth', 1.00,...
           'Color', [0 0 1]);

if h==1 # Eixo X=frequência
  xlabel('Frequência (Hz)');
  # Ajusta os labels das marcas em X manualmente - Frequência
  set(gca, "xticklabel", {'', '60', '', '300', '', '540', '', '780', '',...
      '1020', '', '1260', '', '1500', '', '1740', '', '1980', '', '2220',...
      '', '2460', '', '2700', '', '2940'});
  # Ajusta o espaçamento das marcas em X - Frequência
  set(gca,'XTick', [0 60 180 300 420 540 660 780 900 1020 1140 1260 1380,...
     1500 1620 1740 1860 1980 2100 2220 2340 2460 2580 2700 2820 2940]);
endif
if h==60 # Eixo X=ordem harmônica
  xlabel(['Ordem Harmônica \it (h_1 = ', num2str(f),' Hz)']);
  # Ajusta os labels das marcas em X manualmente - Ordem Harmônica
  set(gca, "xticklabel", {'', '1', '3', '5', '7', '9', '', '13', '', '17', '',...
      '21', '', '25', '', '29', '', '33', '', '37', '', '41', '', '45', '',...
      '49', ''});
  # Ajusta o espaçamento das marcas em X - Ordem Harmônica
  set(gca,'XTick', [0 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39,...
    41 43 45 47 49 51]);
endif

# Ajusta o espaçamento das marcas em X - tempo ms
#set(gca,'XTick', [0 : 60/h : 60*51/h]);

#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Salva figura do espectro harmônico
#print('harmonicas.svg', '-dsvg', '-S320,200', '-FCambriaMath:4');

#print('harmonicas.svg', '-dsvg', '-S320,200');
