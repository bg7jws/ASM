#include <stdio.h>
#include <string.h>

int kmp(char *text, char *search_string);								;kmp有两个输入参数 *text是目标字符串, search_string是键盘输入的模字符串

int main(int argc, char **argv){

	if(argc != 2){														;如果命令行参数错误的显示
		printf("Invalid command line arguments\n");
		return -1;
	}
	

	char *text = argv[1];												;*text赋值串首地址
	
	
	printf("Search pattern: ");
	char search_string[strlen(text)];									;定义search_string最长空间为strlen(text)
	fscanf(stdin, "%s", search_string);									;获取模串的键盘输入
	
	printf("Prefix table:\n");											;显示Prefix table:换行
	int first_position	= kmp (text, search_string);					;调用kmp函数计算first_position
	
	printf("\n");														;换行
	if(first_position==101)												;如果返回值等于101，显示未找到
		printf("The search pattern could not find in the text.\n");
	else
		printf("First position: %d (index starting from 0)\n", first_position);找到显示first_position的十进制整数值

	return(0);
}
