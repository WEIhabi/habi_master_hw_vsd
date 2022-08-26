int main(void) {
	extern int mul1;
	extern int mul2;
	extern int _test_start;
	long long ans;

	ans = (long long) mul1 * mul2;

	*(&_test_start) = ans;
	*(&_test_start + 1) = ans >> 32;

	return 0;
}