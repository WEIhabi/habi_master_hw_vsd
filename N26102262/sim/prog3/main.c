int GCD (int num1, int num2) {
	num1 = num1 % num2;
	if (num1 == 0) return num2;
	else return GCD(num2, num1);
}

int main () {
	extern int div1;
	extern int div2;
	extern int _test_start;

	if (div1 < div2) {
		int temp = div1;
		div1 = div2;
		div2 = temp;
	}

	*(&_test_start) = GCD(div1, div2);
	
	return 0;
}