#import sys
import argparse

def main(y_file_path, r_file_path):
    print(f"Y file path: {y_file_path}")
    print(f"R file path: {r_file_path}")
    # Your script logic here

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process some file paths.')
    parser.add_argument('y_file_path', type=str, help='Path to Y file')
    parser.add_argument('r_file_path', type=str, help='Path to R file')

    args = parser.parse_args()
    main(args.y_file_path, args.r_file_path)
    
def fib(n):
    if (n == 0 or n == 1):
        return 1
    else:
        return fib(n - 1) + fib(n - 2)
    
print(fib(20))