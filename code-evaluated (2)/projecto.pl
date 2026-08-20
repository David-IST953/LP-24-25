% David Borges ist1114702
:- use_module(library(clpfd)). % para poder usar transpose/2
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % ver listas completas
:- [codigoAuxiliar]. % Ficheiro dado. Não alterar.
:- [puzzles]. % Ficheiro dado. A avaliação terá mais puzzles.
% Atenção: nao deves copiar nunca os puzzles para o teu ficheiro de código
% Nao remover nem modificar as linhas anteriores. Obrigado.
% Segue-se o código
%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%5.1 visualização
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Predicado visualiza/1
% Imprime um tabuleiro (lista de listas), linha por linha.
visualiza([]).
visualiza([Linha|Restante]) :-
    write(Linha), nl, % Imprime a linha atual.
    visualiza(Restante). % Processa as linhas restantes.

% Predicado visualizaLinha/1
% Imprime os elementos de uma lista, numerando-os por índice.
visualizaLinha(Lista) :-
    visualizaLinha(Lista, 1). % Inicia a impressão com índice 1.

visualizaLinha(Lista) :-
    visualizaLinha(Lista, 1). % Inicia a contagem a partir de 1.

visualizaLinha([], _). % Caso base: Lista vazia
visualizaLinha([Elemento|Restante], N) :-
    write(N), write(': '), write(Elemento), nl, % Escreve o índice, ": " e o elemento
    N1 is N + 1, % Incrementa o índice
    visualizaLinha(Restante, N1). % Chama recursivamente para o restante da lista


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%5.2 Inserção de estrelas e pontos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Predicado insereObjecto/3
% Insere um objeto numa posição do tabuleiro, se a célula estiver livre.
% Se a célula já estiver ocupada, mantém o valor existente.
insereObjecto((L, C), Tabuleiro, Obj) :-
    (nth1(L, Tabuleiro, Linha), nth1(C, Linha, Elem) -> % Verifica se a posição é válida.
        (var(Elem) -> Elem = Obj ; true) % Insere o objeto se a célula estiver livre.
    ; true). % Ignora se a posição não for válida.

% Predicado insereVariosObjectos/3
% Insere vários objetos no tabuleiro, em posições especificadas.
insereVariosObjectos([], _, []). % Caso base: lista de coordenadas vazia.
insereVariosObjectos([(L, C)|RestCoordenadas], Tabuleiro, [Obj|RestObjs]) :-
    insereObjecto((L, C), Tabuleiro, Obj), % Insere um objeto na posição (L, C).
    insereVariosObjectos(RestCoordenadas, Tabuleiro, RestObjs). % Continua com as coordenadas restantes.

% Predicado inserePontosVolta/2
% Insere 'p' ao redor de uma posição específica no tabuleiro.
inserePontosVolta(Tabuleiro, (L, C)) :-
    findall((NL, NC), % Encontra todas as coordenadas ao redor de (L, C).
            (between(-1, 1, DL), between(-1, 1, DC), % Variações de -1 a 1.
             (DL \= 0 ; DC \= 0), % Ignora a própria posição (L, C).
             NL is L + DL, NC is C + DC), % Calcula as novas coordenadas.
            ListaCoords),
    inserePontos(Tabuleiro, ListaCoords), !. % Insere 'p' nessas posições.

% Predicado inserePontos/2
% Nota: Só insere 'p' (pontos) nas células que estão vazias (variáveis livres).
% Ignora células que já possuem valores (como 'e').
inserePontos(_, []) :- !. % Caso base: lista de coordenadas vazia.
inserePontos(Tabuleiro, [(L, C) | Resto]) :-
    (   nth1(L, Tabuleiro, Linha), % Verifica se a linha existe.
        nth1(C, Linha, Elem),     % Verifica se a coluna existe.
        var(Elem) -> Elem = p     % Insere 'p' apenas se a célula estiver livre.
    ;   true                      % Ignora caso contrário.
    ),
    inserePontos(Tabuleiro, Resto), !. % Continua com as coordenadas restantes.


%%%%%%%%%%%%%%%%%
% 5.3 Consultas
%%%%%%%%%%%%%%%%%

% Predicado objectosEmCoordenadas/3
% Obtém os valores (objetos ou 'v') de uma lista de coordenadas no tabuleiro.
objectosEmCoordenadas([], _, []). % Caso base: lista de coordenadas vazia.
objectosEmCoordenadas([(L, C)|RestCoordenadas], Tabuleiro, [Obj|RestObjs]) :-
    nth1(L, Tabuleiro, Linha), % Acessa a linha L.
    nth1(C, Linha, Elem),      % Acessa o elemento na coluna C.
    (var(Elem) -> Obj = v ; Obj = Elem), % 'v' se a célula estiver livre; caso contrário, o objeto.
    objectosEmCoordenadas(RestCoordenadas, Tabuleiro, RestObjs). % Processa as coordenadas restantes.

% Predicado coordObjectos/5
% Filtra as coordenadas onde se encontram determinados objetos no tabuleiro.
coordObjectos(Objecto, Tabuleiro, ListaCoords, ListaCoordObjs, NumObjectos) :-
    findall((L, C), % Encontra coordenadas que correspondem ao objeto.
            (member((L, C), ListaCoords), % Percorre a lista de coordenadas.
             nth1(L, Tabuleiro, Linha),  % Acessa a linha L.
             nth1(C, Linha, Elem),       % Acessa o elemento na coluna C.
             (var(Objecto) -> var(Elem) ; Elem == Objecto)), % Verifica se corresponde ao objeto.
            ListaCoordObjs),
    length(ListaCoordObjs, NumObjectos). % Conta o número de objetos encontrados.


% Predicado coordenadasVars/2
% Retorna todas as coordenadas de células livres (variáveis) no tabuleiro.
coordenadasVars(Tabuleiro, ListaVars) :-
    findall((L, C),                    % Procura todas as coordenadas (L, C).
            (nth1(L, Tabuleiro, Linha), nth1(C, Linha, Elem), var(Elem)), % Verifica se são livres.
            ListaVars).                % Lista de coordenadas livres.


%###########################################
%5.4 Estrategias.
% 5.4.1 Fechar Linhas, colunas ou estruturas.
%###########################################


% Predicado fechaListaCoordenadas/2
% Este predicado trata as coordenadas em regiões específicas de um tabuleiro. Dependendo do
% número de estrelas (e) e células livres, toma ações diferentes:
% - Caso existam 2 estrelas, insere pontos em todas as coordenadas.
% - Caso 1 estrela e 1 célula livre, preenche a célula livre com 'e'.
% - Caso nenhuma estrela e 2 células livres, preenche ambas as células livres com 'e'.
% Caso contrário, não faz alterações.
fechaListaCoordenadas(Tab, ListaCoords) :-
    contaEstrelasELivres(Tab, ListaCoords, NumE, NumL, Livres), % Conta estrelas e livres.
    (  ( NumE=:=2 ->                     % Se já existem 2 estrelas.
         preencheComPontos(Tab, ListaCoords) % Preenche o resto com pontos.
       )
     ;  ( NumE=:=1, NumL=:=1 ->           % Se há 1 estrela e 1 livre.
         Livres=[CoordLivre|_],           % Encontra a célula livre.
         insereObjecto(CoordLivre, Tab, e), % Insere uma estrela.
         inserePontosVolta(Tab, CoordLivre) % Preenche ao redor com pontos.
       )
     ;  ( NumE=:=0, NumL=:=2 ->           % Se não há estrelas e 2 livres.
         Livres = [C1, C2|_],             % Encontra as duas células livres.
         insereObjecto(C1, Tab, e),       % Insere a primeira estrela.
         inserePontosVolta(Tab, C1),      % Preenche ao redor com pontos.
         insereObjecto(C2, Tab, e),       % Insere a segunda estrela.
         inserePontosVolta(Tab, C2)       % Preenche ao redor com pontos.
       )
     ;  true                              % Caso contrário, não faz nada.
    ),!.

% Predicado auxiliar do fechaListaCoordenadas, contaEstrelasELivres.
% Conta o número de estrelas e células livres em uma lista de coordenadas.
contaEstrelasELivres(_, [], 0, 0, []). % Caso base: lista vazia.
contaEstrelasELivres(Tab, [(L, C)|T], E, Lb, [(L, C)|LT]) :-
    nth1(L, Tab, Linha),                % Acessa a linha L.
    nth1(C, Linha, Val),                % Acessa a coluna C.
    ( var(Val) ; Val == '_' ), !,       % Verifica se a célula é livre.
    contaEstrelasELivres(Tab, T, E, L0, LT), % Processa o resto da lista.
    Lb is L0 + 1.                       % Incrementa o contador de livres.
contaEstrelasELivres(Tab, [(L, C)|T], E, Lb, LT) :-
    nth1(L, Tab, Linha),
    nth1(C, Linha, Val),
    Val == e, !,                        % Verifica se a célula contém uma estrela.
    contaEstrelasELivres(Tab, T, E0, Lb, LT),
    E is E0 + 1.                        % Incrementa o contador de estrelas.
contaEstrelasELivres(Tab, [_|T], E, Lb, LT) :-
    contaEstrelasELivres(Tab, T, E, Lb, LT). % Continua com o restante.

% Predicado auxiliar do fechaListaCoordenadas, preencheComPontos.
% Preenche células livres com pontos ('p') em uma lista de coordenadas.
preencheComPontos(_, []). % Caso base: lista vazia.
preencheComPontos(Tab, [(L, C)|T]) :-
    nth1(L, Tab, Linha),                % Acessa a linha L.
    nth1(C, Linha, Val),                % Acessa a coluna C.
    ( var(Val) -> Val = p               % Preenche com 'p' se estiver livre.
    ; Val == '_' -> Val = p             % Ou se for marcado como livre.
    ; true                              % Caso contrário, não faz nada.
    ),
    preencheComPontos(Tab, T).          % Continua com o restante.

% Predicado fecha/2
% Aplica o predicado fechaListaCoordenadas a uma lista de listas de coordenadas.
fecha(_, []) :- !. % Caso base: quando não há mais listas, termina.
fecha(Tabuleiro, [ListaCoords | RestoListasCoords]) :-
    % Aplica o fechamento à lista de coordenadas atual.
    fechaListaCoordenadas(Tabuleiro, ListaCoords),
    % Continua processando o restante das listas.
    fecha(Tabuleiro, RestoListasCoords).


%%%%%%%%%%%%%%%%%%%%%%%%%%
%5.4.2 Encontrar Padrões.
%%%%%%%%%%%%%%%%%%%%%%%%%%

% Predicado encontraSequencia/4
encontraSequencia(Tab, N, ListaCoords, Seq) :-
    sublistaConsecutiva(ListaCoords, N, Seq),  % Identifica sublista consecutiva de tamanho N
    todasLivres(Tab, Seq),                     % Verifica se todas as células da sequência são livres
    bordasNaoLivres(Tab, ListaCoords, Seq),!.    % Valida bordas antes e depois da sequência

% predicado auxiliar do encontra sequencia, todasLivres
% Verifica se todas as células da sequência são livres
todasLivres(_, []).
todasLivres(Tab, [(L, C)|T]) :-
    nth1(L, Tab, Linha),
    nth1(C, Linha, Val),
    var(Val),  % Garante que a célula é livre (variável)
    todasLivres(Tab, T).

% Predicado auxiliar do encontra sequencia, bordasNaoLivres
% Valida as bordas relevantes da sequência
bordasNaoLivres(Tab, Lista, Seq) :-
    append(Frente, Resto, Lista),     % Divide a lista em antes e depois da sequência
    append(Seq, Fim, Resto),          % Isola a sequência central
    validaBorda(Tab, Frente),         % Valida a borda antes da sequência
    validaBorda(Tab, Fim).            % Valida a borda depois da sequência

% Predicado auxiliar do encontra sequencia, sublistaConsecutiva
% Encontra uma sublista consecutiva de tamanho N em uma lista
sublistaConsecutiva(L, N, S) :-
    length(S, N),               % Define o comprimento da sublista
    append(_, Resto, L),        % Divide a lista original em partes
    append(S, _, Resto).

%predicado auxiliar do encontra sequencia, ValidaBorda
% Valida uma borda
validaBorda(_, []). % Bordas vazias são válidas
validaBorda(Tab, [(L, C)|T]) :-
    nth1(L, Tab, Linha),
    nth1(C, Linha, Val),
    \+ var(Val),  % A borda deve conter um valor fixo
    Val \= e,     % A borda não pode conter uma estrela
    validaBorda(Tab, T). % Valida o restante da borda

% Predicado aplicaPadraoI/2
% Aplica o padrão 'I' (estrela central e duas estrelas nas extremidades) ao tabuleiro.
aplicaPadraoI(Tabuleiro, [(L1, C1), (L2, C2), (L3, C3)]) :-
    nth1(L2, Tabuleiro, Linha2),
    nth1(C2, Linha2, Elem2),
    var(Elem2),                          % Garante que a célula central está livre.
    insereObjecto((L1, C1), Tabuleiro, e), % Insere estrelas nas extremidades.
    insereObjecto((L3, C3), Tabuleiro, e),
    inserePontosVolta(Tabuleiro, (L1, C1)), % Preenche ao redor das estrelas com pontos.
    inserePontosVolta(Tabuleiro, (L3, C3)).

% Predicado aplicaPadroes/2
% Este predicado aplica os padrões I e T às sequências de coordenadas
aplicaPadroes(_, []). % Caso base: lista de coordenadas vazia
aplicaPadroes(Tab, [CoordAtual|OutrasCoords]) :-
    (   encontraSequencia(Tab, 4, CoordAtual, Sequencia4) ->
        aplicaPadraoT(Tab, Sequencia4)
    ;   encontraSequencia(Tab, 3, CoordAtual, Sequencia3) ->
        aplicaPadraoI(Tab, Sequencia3)
    ),
    aplicaPadroes(Tab, OutrasCoords). % Continua a processar o restante das coordenadas
aplicaPadroes(Tab, [_|OutrasCoords]) :-
    aplicaPadroes(Tab, OutrasCoords). % Caso nenhuma sequência seja encontrada, pula para o próximo.

%%%%%%%%%%%%%%%%%%%%%%
% 5.5 Apoteose Final.
%%%%%%%%%%%%%%%%%%%%%%

% Predicado resolve/2
resolve(Estruturas, Tabuleiro) :-
    coordTodas(Estruturas, CoordenadasTotais), % Obtém todas as coordenadas do tabuleiro
    loop_resolve(CoordenadasTotais, Tabuleiro),!. % Inicia o loop de resolução

% Predicado loop_resolve/2
loop_resolve(CoordenadasTotais, Tabuleiro) :-
    coordenadasVars(Tabuleiro, Antes), % Obtém as variáveis no tabuleiro antes das operações
    aplicaPadroes(Tabuleiro, CoordenadasTotais), % Aplica os padrões
    fecha(Tabuleiro, CoordenadasTotais), % Aplica o predicado fecha
    coordenadasVars(Tabuleiro, Depois), % Obtém as variáveis no tabuleiro após as operações
    (   Antes = Depois % Verifica se o tabuleiro estabilizou
    ->  true % Se estabilizou, o loop termina
    ;   loop_resolve(CoordenadasTotais, Tabuleiro) % Caso contrário, repete o loop
    ).

