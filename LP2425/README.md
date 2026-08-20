# lp24 - projecto

Este repositório git pertence a ist1114702 e destina-se ao projecto de lp24.

O enunciado do projecto está disponível em [enunciado_projecto.pdf](enunciado_projecto.pdf).

Os estudantes devem submeter aqui a sua solução para o projecto que será avaliada automaticamente.

O resultado da avaliação do projecto ficará disponível no [README](https://gitlab.rnl.tecnico.ulisboa.pt/lp/lp24/feedback/projecto/ist1114702/-/tree/master/README.md) do repositório de feedback após cada submissão de código.

O desempenho global dos estudantes no projecto pode ser consultado no [_dashboard_](https://gitlab.rnl.tecnico.ulisboa.pt/lp/lp24/lp24/-/tree/master/dashboard/projects/projecto.md) do projecto, presente no repositório global de lp24.

- **Notas importantes:**

    - [+Os estudantes têm de esperar 15 minuto(s) entre submissões+]. Desta forma, têm de esperar 15 minuto(s) para resubmeter um novo programa. Caso contrário a submissão do estudante não será avaliada.

    - [-Os estudantes não podem alterar o ficheiro .gitlab-ci.yml presente no repositorio. A alteração deste ficheiro fará com que o estudante fique sem acesso a este repositório, não existirão excepções. Desta forma o estudante será avaliado com 0 valores nesta componente de avaliação-].

    - O projecto deve ser desenvolvido usando o [SWI Prolog](https://www.swi-prolog.org).

- O projecto pode ser testado localmente correndo os testes públicos, correndo:

    ```
    swipl -l projecto.pl -g run_tests -t halt testes_publicos.plt
    ```

- Resultados de avaliação mais comuns para cada teste de avaliação:

    - _Successful_ : O teste executou corretamente.

    - _Unsuccessful_ : O teste não executou corretamente.

    - _Time Limit Exceeded_ : O tempo de execução do programa programa excedeu o tempo permitido.

    - _Memory Limit Exceeded_ : A memória de execução do programa excedeu a memória permitida.

    - Outros : Ocorreu um erro durante a execução do programa que levou à paragem inesperada do mesmo.
