#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv)
{
    if (argc < 4)
        return 1;
    FILE *input = fopen(argv[1], "r");
    FILE *output = fopen(argv[2], "w");
    unsigned char out[5];
    out[4] = 0;
    out[0] = fgetc(input);
    out[1] = fgetc(input);
    out[2] = fgetc(input);
    out[3] = fgetc(input);
    int three_times = 0;
    u_int16_t unsigned_input_sample;
    int16_t input_sample;
    int32_t input_sample_bigger;
    u_int16_t output_sample;
    int loop = 0;
    u_int32_t size = 0;
    u_int32_t samples;
    while (strcmp("data", out) != 0)
    {
       for (int i = 0; i < 3; i++)
            out[i] = out[i+1];
       out[3] = fgetc(input);
    }

    out[0] = fgetc(input);
    out[1] = fgetc(input);
    out[2] = fgetc(input);
    out[3] = fgetc(input);
    
    size = out[3];
    size = ((size<<8) & 0xffffff00) + out[2];
    size = ((size<<8) & 0xffffff00) + out[1];
    size = ((size<<8) & 0xffffff00) + out[0];
    
    samples = size/2;
    out[0] = (0x000000ff  & samples);
    out[1] = (0x000000ff  & (samples>>4));
    out[2] = (0x000000ff  & (samples>>8));
    out[3] = (0x000000ff  & (samples>>12));

    fprintf(output, "%s_size:\n.byte 0x%02x,0x%02x,0x%02x,0x%02x\n%s:\n", argv[3], out[0], out[1], out[2], out[3], argv[3]);


    for(u_int32_t i = 0; i < size; i++)
    {
       out[three_times] = fgetc(input);
       if (three_times < 1)
       {
           three_times++;
           continue;
       }    
       three_times = 0;
       unsigned_input_sample = (u_int16_t) out[0];
       unsigned_input_sample += 256*((u_int16_t)out[1]);
       input_sample = (int16_t) unsigned_input_sample;
       input_sample_bigger = (int32_t) input_sample;
       input_sample_bigger = input_sample_bigger + 32768;
       output_sample = (u_int16_t) input_sample_bigger;
       output_sample = (0x0fff & (output_sample>>4));
       printf("hex %#010x\n", output_sample);
       out[0] = (unsigned char)(0x00ff & output_sample);
       printf("char 0 %i\n", output_sample);
       out[1] = 16 + (unsigned char)(0x00ff & (output_sample>>8));
       printf("char 1 %i\n", output_sample);
       fprintf(output, ".byte 0x%02x,0x%02x\n", out[1], out[0]);
       fprintf(stdout, ".byte 0x%02x,0x%02x\n", out[0], out[1]);
       printf("%i\n", loop);
       loop++;
    }
    fclose(input);
    fclose(output);
    return 0;
}
