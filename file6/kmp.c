#include <stdio.h>
#include <string.h>

int kmp(char *text, char *search_string);								;kmp������������� *text��Ŀ���ַ���, search_string�Ǽ��������ģ�ַ���

int main(int argc, char **argv){

	if(argc != 2){														;��������в����������ʾ
		printf("Invalid command line arguments\n");
		return -1;
	}
	

	char *text = argv[1];												;*text��ֵ���׵�ַ
	
	
	printf("Search pattern: ");
	char search_string[strlen(text)];									;����search_string��ռ�Ϊstrlen(text)
	fscanf(stdin, "%s", search_string);									;��ȡģ���ļ�������
	
	printf("Prefix table:\n");											;��ʾPrefix table:����
	int first_position	= kmp (text, search_string);					;����kmp��������first_position
	
	printf("\n");														;����
	if(first_position==101)												;�������ֵ����101����ʾδ�ҵ�
		printf("The search pattern could not find in the text.\n");
	else
		printf("First position: %d (index starting from 0)\n", first_position);�ҵ���ʾfirst_position��ʮ��������ֵ

	return(0);
}
