#include "rns.h"
#include <stdio.h>

char* convert_int32_to_binary_representation(int number)
{
	const bitsCount = 32;
	char* result = (char*)malloc(sizeof(char) * (bitsCount + 1));
	for (int i = 0; i < bitsCount; i++)
	{
		result[31 - i] = (number & (1 << i)) != 0 ? '1' : '0';
	}
	result[bitsCount] = NULL;
	return result;
}

int32_t* read_numbers_from_file(char* filename, int32_t* numbers_count, char separator)
{
	char num_with_separator[3] = "%d";
	num_with_separator[2] = separator;

	// read first number from file and save it in numbers_count
	FILE* file;
	fopen_s(&file, filename, "r");
	fscanf_s(file, num_with_separator, numbers_count);

	// read the other numbers from file and save them to numbers_from_file array
	int32_t* numbers_from_file = (int32_t*)malloc(sizeof(int32_t) * (*numbers_count));
	for (int i = 0; i < *numbers_count; i++)
	{
		fscanf_s(file, num_with_separator, &numbers_from_file[i]);
	}
	fclose(file);
	return numbers_from_file;
}

int main(int argc, char* argv[])
{
	char* input_filename = argv[1];
	char* output_filename = argv[2];
	char* output_filename_rns = argv[3];

	// remove the files if they already exist
	remove(output_filename);
	remove(output_filename_rns);

	// read coefficients from file
	int32_t itemsCount = 0;
	int32_t* items = read_numbers_from_file(input_filename, &itemsCount, ',');

	// create the files for the output
	FILE* output_file;
	fopen_s(&output_file, output_filename, "a");
	FILE* output_file_rns;
	fopen_s(&output_file_rns, output_filename_rns, "a");

	// convert items to binary and to rns representation and write in corresponding file 
	for (size_t j = 0; j < itemsCount; j++)
	{
		fprintf(output_file, "%s\n", convert_int32_to_binary_representation(items[j]));
		fprintf(output_file_rns, "%s\n", convert_int32_to_binary_representation((int32_t)int_to_rns((uint32_t)items[j])));
	}

	fclose(output_file);
	fclose(output_file_rns);

	return 0;
}