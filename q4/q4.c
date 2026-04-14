#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    char line[128];

    while (fgets(line, sizeof(line), stdin) != NULL){
        char op[6];
        char lib_path[32];
        int num1;
        int num2;

        if (sscanf(line, "%5s %d %d", op, &num1, &num2)!=3){
            continue;
        }

        if (snprintf(lib_path, sizeof(lib_path), "./lib%s.so", op)>=(int)sizeof(lib_path)){
            fprintf(stderr, "library path too long\n");
            return 1;
        }

        
        void *handle = dlopen(lib_path, RTLD_NOW | RTLD_LOCAL);
        if (handle == NULL){
            fprintf(stderr, "%s\n", dlerror());
            return 1;
        }

        dlerror();
        int (*operation)(int, int) = (int (*)(int, int))dlsym(handle, op);
        const char *error = dlerror();
        if (error != NULL){
            fprintf(stderr, "%s\n", error);
            dlclose(handle);
            return 1;
        }

        printf("%d\n", operation(num1, num2));

        if (dlclose(handle) != 0){
            fprintf(stderr, "%s\n", dlerror());
            return 1;
        }
    }

    return 0;
}
