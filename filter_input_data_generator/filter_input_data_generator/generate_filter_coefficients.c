#include "rns.h"
#include <stdio.h>

int32_t* read_file(char* file_name, int32_t* count)
{
	FILE* myFile;
	fopen_s(&myFile, file_name, "r");
	fscanf_s(myFile, "%d,", count);

	int32_t* array = (int32_t*)malloc(sizeof(int32_t) * (*count));

	for (int i = 0; i < *count; i++) {
		fscanf_s(myFile, "%d,", &array[i]);
	}

	fclose(myFile);

	return array;
}

char* int32ToBinary(int n)
{
	char* result = (char*)malloc(sizeof(char) * 33);

	for (int i = 0; i < 32; i++)
		result[31 - i] = (n & (1 << i)) != 0 ? '1' : '0';
	result[32] = NULL;

	return result;
}

void generatefilterCoefficients(char* input_filename, char* output_filename, char* output_filename_rns) {
	remove(output_filename);
	remove(output_filename_rns);

	int32_t coefsCount = 0;
	int32_t* coefs = read_file(input_filename, &coefsCount);

	FILE* coefs_file;
	fopen_s(&coefs_file, output_filename, "a");
	FILE* coefs_file_rns;
	fopen_s(&coefs_file_rns, output_filename_rns, "a");

	for (size_t j = 0; j < coefsCount; j++)
	{
		fprintf(coefs_file, "%s\n", int32ToBinary(coefs[j]));
		fprintf(coefs_file_rns, "%s\n", int32ToBinary((int32_t)int_to_rns((uint32_t)coefs[j])));
	}

	fclose(coefs_file);
	fclose(coefs_file_rns);
}

int main(int argc, char* argv[])
{
	char* coefs_input_file_name = argv[1];
	char* coefs_file_name = argv[2];
	char* coefs_file_name_rns = argv[3];

	generatefilterCoefficients(coefs_input_file_name, coefs_file_name, coefs_file_name_rns);

	return 0;
}