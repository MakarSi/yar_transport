% Parameters
int: T;  % горизонт планирования
int: n;  % количество остановок
int: m;  % количество транспортных средств
int: cp; % вместимость транспортного средства
int: M;  
set of int: nws = 1..n-1;
set of int: nw = 2..n;
set of int: Tw = 1..T;
array[nws] of int: p;             % время движения между остановками i и i+1
array[nw] of int: P;              % время движения между остановками 1 и i 
array[nws, nw, Tw] of int: g;     % количество пассажиров, приходящее в момент времени t на станцию i с целью отправиться на станцию j > i


% Variables
array[nws, nw, Tw] of var int: x; % количество пассажиров, которые отправились со станции i на станцию j в момент времени t 
array[nws, Tw] of var bool: y;    % отправился ли транспорт от остановки i в момент времени t
array[nws, Tw] of var int: z;     % количество пассажиров, оставшихся на остановке i по окончанию момента времени t


% Constraints
% x, z должны быть положительными
constraint forall(i in nws, j in nw, t in Tw)(x[i, j, t] >= 0); 
constraint forall(i in nws, t in Tw)(z[i, t] >= 0); 

% выражение z через g и x
constraint forall(i in 1..(n-1), t in 1..T)(
              z[i, t] = sum(dj in (i+1)..n, dt in 1..t)(g[i, dj, dt]) - sum(dt in 1..t, dj in (i+1)..n)(x[i, dj, dt])
              );
              
% Пассажиры начинают движение, только при прибытии транспорта, и в транспорт садится не более его вместимости
constraint forall(i in 1..(n-1), t in 1..T)(cp * y[i, t] >= sum(j in (i+1)..n)(x[i, j, t]));

% Вместимость транспортного средства не нарушается для любого участка движения
constraint forall(i in 1..(n-1))(forall(t in 1..T-P[i+1])(sum(k in 1..i, j in (i+1)..n)(x[k, j, t + P[i+1]]) <= cp));

% Время отправления транспорта от последующих станций зависит от времени отправления от первой станции
constraint forall(i in 2..(n-1), t in 1..T-P[i], dt in 1..P[i])(y[1,t] == y[i, t + P[i]]);

%constraint forall(i in 1..(n-1), t in 1..T)(z[i, t] <= y[i,t] * cp);

% Все пассажиры доезжают до своей станции к концу горизонта планирования
constraint forall(i in 1..n-1, j in (i+1)..n, t in T-sum(k in i..j-1)(p[k])..T)(x[i,j,t] == 0);

% В конце горизонта планирования все остановки пустые
constraint forall(i in 1..(n-1))(z[i, T-1] == 0);

% Один автобус не может находиться на нескольких рейсах одновременно
constraint forall(i in 2..(n-1), t in 1..T-P[i], dt in 0..P[i]-1)(if y[1, t] == 1 then y[i, t + dt] = 0 else true endif);

constraint forall(i in 2..(n-1))(forall(t in 1..P[i])(y[i,t] == 0));

constraint forall(t in 1..(T - P[n]))(forall(dt in 1..P[n])(if y[1, t] == 1 then y[1, t+dt] = 0 else true endif));


% Objective
solve minimize sum(i in 1..n-1, j in 1..T)(z[i, j]);


% Output
output ["X matrix \n"];
output [show_int(2, x[i,j,t]) ++ if j == n /\ t == T then "\n" else if t == T then "    " else " " endif endif | i in nws, j in nw, t in Tw];
output ["Y matrix \n"];
output [show_int(1, y[i,t]) ++ if t == T then "\n" else " " endif | i in nws, t in Tw];
output ["Z matrix \n"];
output [show_int(2, z[i,t]) ++ if t == T then "\n" else " " endif | i in nws, t in Tw];