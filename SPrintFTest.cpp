
#include <iostream>
#include <cstdlib>
#include <ctime>
#include <string>
#include <stdio.h>

using namespace std;

int main()
{
    char* temp;
    temp=new char[10];
    char buffer[10];
    int x;
    x=sprintf(buffer,"testing123");
    x=sprintf(temp,"testing...");
    cout<<x<<endl;
    cout<<buffer<<endl;
    cout<<temp<<endl;
}