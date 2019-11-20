clc;
clear;
syms P1 P2 P3;
X=[P1;0;0;0;P2;0;0;0;P3];

Gencap=xlsread('data1','Gencap');
Linecap=xlsread('data1','Linecap');
Loaddata=xlsread('data1','Loaddata');
Costdata=xlsread('data1','Costdata');

H=diag(Costdata(:,2));
C=Costdata(:,3);
Cost=0.5*X'*H*X+C'*X;%目标函数 
lb=Gencap(3,:);%边界下约束条件
ub=Gencap(2,:);%边界上约束条件
Pd=Loaddata(2,:);%负荷信息
Aeq=ones(1,9);
beq=Aeq*Pd';
n=9;
B=zeros(n-1,n-1);
K=zeros(n,n-1);
for i=1:n
    if Linecap(i,1)<n
        B(Linecap(i,1),Linecap(i,1))=B(Linecap(i,1),Linecap(i,1))+1/Linecap(i,3);
    end
    if Linecap(i,2)<n
        B(Linecap(i,2),Linecap(i,2))=B(Linecap(i,2),Linecap(i,2))+1/Linecap(i,3);
    end
    if Linecap(i,1)<n&&Linecap(i,2)<n
        B(Linecap(i,1),Linecap(i,2))=-1/Linecap(i,3);
        B(Linecap(i,2),Linecap(i,1))=-1/Linecap(i,3);
    end
end%计算B矩阵

for k=1:n
    lab1=min(Linecap(k,1),Linecap(k,2));
    lab2=max(Linecap(k,1),Linecap(k,2));
       if lab2==n
       K(k,lab1)=1/Linecap(k,3);
       else
       K(k,lab1)=1/Linecap(k,3);
       K(k,lab2)=-1/Linecap(k,3); 
       end
end%计算K矩阵

T1=K/B;
bb=zeros(n,1);
T=[T1 bb];
A=[T;-T];
cc=[Linecap(:,4);Linecap(:,4)];
b=A*Pd'+cc;
[xopt,fopt]=quadprog(H,C,A,b,Aeq,beq,lb,ub);
disp(xopt);
disp(fopt);%最优潮流程序
Pdact=Pd;
LMP=zeros(1,9);
for i=1:9
    Pdact(i)=Pd(i)+1;
    b=A*Pdact'+cc;
    beq=Aeq*Pdact';
    [xoptact,foptact]=quadprog(H,C,A,b,Aeq,beq,lb,ub);
    LMP(i)=foptact-fopt;
    Pdact(i)=Pdact(i)-1;
end%计算节点电价
