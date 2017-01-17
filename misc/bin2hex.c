#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
int main(int argc, char** argv){
    FILE* infile = stdin;
    FILE* outfile = stdout;
    if(argc >= 2){
        infile = fopen(argv[1],"rb");
        if(!infile){
            fprintf(stderr,"Error opening input: %s\n",argv[1]);
            exit(1);
        }
    }
    if(argc >= 3){
        outfile = fopen(argv[2],"w");
        if(!outfile){
            fprintf(stderr,"Error opening output: %s\n",argv[2]);
            exit(1);
        }
    }
   uint16_t buf; 
   size_t bytes;
   while((bytes = fread(&buf,sizeof(buf),1,infile)) > 0){
        fprintf(outfile,"%04x\n",buf);
   }

    exit(0);
}
