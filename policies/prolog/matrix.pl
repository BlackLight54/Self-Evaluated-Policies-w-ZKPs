% matrix.pl
% Tresholds
rolling_treshold('low', 0).
rolling_treshold('mid', 3000).
rolling_treshold('high',7000).

savings_treshold('low',250).
savings_treshold('mid',500).
savings_treshold('high',1000).

% Supportmatrix
% support_matrix(Rolling_class, savings_class, type, value)
support_matrix('low', 'low', 'nominal', 500).
support_matrix('low', 'mid', 'percent', 10).
support_matrix('low', 'high', 'nominal', 500).
support_matrix('mid', 'low', 'nominal', 500).
support_matrix('mid', 'mid', 'nominal', 500).
support_matrix('mid', 'high', 'nominal', 500).
support_matrix('high', 'low', 'nominal', 500).
support_matrix('high', 'mid', 'nominal', 500).
support_matrix('high', 'high', 'nominal', 500).

% Social Suports: social_suport(credType,type,value)
social_suport('ChangedWorkcapacityCredential','nominal',10000).