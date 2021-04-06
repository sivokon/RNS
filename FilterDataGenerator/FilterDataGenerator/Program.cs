using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Numerics;
using System.Text;

namespace FilterDataGenerator
{
    class Program
    {
        private static BigInteger MaxInt;
        private static BigInteger IntRnsDelta;
        private const int IntBitsCount = 64;
        private const int RnsBitsCount = 65;

        private static List<BigInteger> M = new List<BigInteger> {
            2, 211, 223, 227, 229, 233, 239, 241, 251
            //233, 239, 241, 251
        };

        private static List<int> S = new List<int> { 
            0, 1, 9, 17, 25, 33, 41, 49, 57,
            //0, 8, 16, 24
        };

        static void Main(string[] args)
        {
            Initialize();

            GenerateСoefficientFiles(args[0]);
            GenerateSignalFiles(args[1]);
        }

        private static void GenerateСoefficientFiles(string inputFileName) =>
            GenerateBinaryAndRnsBinaryRepresentionFiles(inputFileName, $"outputCoefficients_{IntBitsCount}.txt", $"outputCoefficients_RNS_{IntBitsCount}.txt");

        private static void GenerateSignalFiles(string inputFileName) =>
            GenerateBinaryAndRnsBinaryRepresentionFiles(inputFileName, $"outputSignal_{IntBitsCount}.txt", $"outputSignal_RNS_{IntBitsCount}.txt");

        private static void GenerateBinaryAndRnsBinaryRepresentionFiles(string inputName, string outputName, string outputNameRns)
        {
            var data = File.ReadAllText(inputName)
                .Split(',')
                .Select(BigInteger.Parse)
                .ToList();
            var signalLength = (int)data[0];
            var signal = new List<string>();
            var signalRns = new List<string>();

            for (int i = 0; i < signalLength; i++)
            {
                signal.Add(ConvertIntToBinaryString(data[i+1], IntBitsCount));
                var rnsRepresentation = ConvertIntToRns(data[i+1]);
                signalRns.Add(ConvertIntToBinaryString(rnsRepresentation, RnsBitsCount));
            }

            File.WriteAllLines(outputName, signal);
            File.WriteAllLines(outputNameRns, signalRns);
        }

        private static string ConvertIntToBinaryString(BigInteger number, int bitsCount)
        {
            var bytes = number.ToByteArray();
            var idx = bytes.Length - 1;
            var base2 = new StringBuilder(bytes.Length * 8);
            var binary = Convert.ToString(bytes[idx], 2);

            if (binary[0] != '0' && number.Sign == 1) base2.Append('0');
            base2.Append(binary);
            for (idx--; idx >= 0; idx--)
                base2.Append(Convert.ToString(bytes[idx], 2).PadLeft(8, '0'));

            var binaryString = base2.ToString();
            binaryString = binaryString.PadLeft(bitsCount, number.Sign >= 0 ? '0' : '1');
            return binaryString.Substring(binaryString.Length - bitsCount, bitsCount);
        }

        private static BigInteger ConvertIntToRns(BigInteger number)
        {
            if (number.Sign == -1)
                number = MaxInt + number - IntRnsDelta;

            var result = (BigInteger)0;
            for (int i = 0; i < M.Count; i++)
                result |= (number % M[i]) << S[i];

            return result;
        }

        private static void Initialize()
        {
            var maxRns = M.Aggregate((acc, e) => acc * e);
            MaxInt = CalculateMaxInt();
            IntRnsDelta = MaxInt - maxRns;
        }

        private static BigInteger CalculateMaxInt()
        {
            var intMax = (BigInteger)1;
            for (int i = 0; i < IntBitsCount; i++)
                intMax *= 2;

            return intMax;
        }
    }
}
