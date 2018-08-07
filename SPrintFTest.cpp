
#include <iostream>
#include <cstdlib>
#include <ctime>
#include <string>
#include <stdio.h>

using namespace std;

int main()
{
    char buffer[10];
    int x;
    x=sprintf(buffer,"testing...");
    cout<<buffer<<endl;
}