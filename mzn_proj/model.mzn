% Parameters
int: T;  % горизонт планирования
int: n;  % количество остановок
int: m;  % количество транспортных средств
int: cp; % вместимость транспортного средства
set of int: nws = 1..n-1;
set of int: nw = 2..n;
set of int: Tw = 1..T;
array[nws] of int: p;             % время движения между остановками i и i+1
array[nw] of int: P;              % время движения между остановками 1 и i  (i от 2 до n)
array[nws] of int: P2;            % время движения между остановками 1 и i  (i от 1 до n-1)
array[nws, nw, Tw] of int: g;     % количество пассажиров, приходящее в момент времени t на станцию i с целью отправиться на станцию j > i


% Variables
array[nws, nw, Tw] of var int: x; % количество пассажиров, которые отправились со станции i на станцию j в момент времени t 
array[nws, Tw] of var 0..m: y;    % сколько транспорта отправилось от остановки i в момент времени t
array[nws, Tw] of var int: z;     % количество пассажиров, оставшихся на остановке i по окончанию момента времени t


% Constraints
% x, z должны быть положительными
constraint forall(i in nws, j in nw, t in Tw)(x[i, j, t] >= 0); 
constraint forall(i in nws, t in Tw)(z[i, t] >= 0); 

% Выражение z через g и x
constraint forall(i in nws, t in Tw)(
              z[i, t] = sum(dj in (i+1)..n, dt in 1..t)(g[i, dj, dt]) - sum(dt in 1..t, dj in (i+1)..n)(x[i, dj, dt])
              );
              
% Количество уехавших с остановки i на j за весь горизонт планирования равняется количеству прибывших 
constraint forall(i in nws, j in nw) (sum(t in Tw) (x[i, j, t]) == sum(t in Tw)(g[i,j,t]));
                                           
% Пассажиры начинают движение только при прибытии транспорта, и в транспорт садится не более его вместимости
constraint forall(i in nws, t in Tw)(cp * y[i, t] >= sum(j in (i+1)..n)(x[i, j, t]));

% Вместимость транспортного средства не нарушается для любого участка движения
constraint forall(t in 1..T-P[n]+1, k in nws)(sum(i in 1..k, j in (k+1)..n)(x[i, j, t + P2[i]]) <= y[1, t] * cp);

% Время отправления транспорта от последующих станций зависит от времени отправления от первой станции
constraint forall(i in 2..(n-1), t in 1..T-P[i], dt in 1..P[i])(y[1,t] == y[i, t + P[i]]);

% Все пассажиры доезжают до своей станции к концу горизонта планирования
constraint forall(i in nws, j in (i+1)..n, t in T-sum(k in i..j-1)(p[k])+1..T)(x[i,j,t] == 0);

% В конце горизонта планирования все остановки пустые
constraint forall(i in nws)(z[i, T-1] == 0);

% Если в момент времени t от станции 1 выехали y[1,t] автобусов, то пока они не закончат рейс, они не могут отправляться от других остановок
% (Тут можно будет добавить время на отдых для водителя)
constraint forall(i in 2..(n-1), t in 1..T-P[i])(if y[1, t] != 0 then sum(dt in 0..P[i]-1)(y[i, t + dt]) <= m - y[1, t] else true endif);
% Тоже самое для первой остановки (неудобная индексация у P, в каждом случае удобнее своя)
constraint forall(t in 1..(T - P[n]))(if y[1, t] != 0 then sum(dt in 1..P[n])(y[1, t+dt]) <= m - y[1, t] else true endif);

% Автобусы не могут появиться на остановке i > 1 до отправления от остановки 1 в начале горизонта планирования
constraint forall(i in 2..(n-1))(forall(t in 1..P[i])(y[i,t] == 0));

% Нет отправлений, если автобус не доедет до конечной в течение горизонта планирования
constraint forall(t in (T-P[n]+1)..T)(y[1, t] == 0);

% Objective
solve minimize sum(i in 1..n-1, j in 1..T)(z[i, j]);

% Output
output ["X matrix \n"];
output [show_int(2, x[i,j,t]) ++ if j == n /\ t == T then "\n" else if t == T then "    " else " " endif endif | i in nws, j in nw, t in Tw];
output ["Y matrix \n"];
output [show_int(2, y[i,t]) ++ if t == T then "\n" else " " endif | i in nws, t in Tw];
output ["Z matrix \n"];
output [show_int(2, z[i,t]) ++ if t == T then "\n" else " " endif | i in nws, t in Tw];
output [show(sum(i in  nws, t in Tw)(z[i,t]))]