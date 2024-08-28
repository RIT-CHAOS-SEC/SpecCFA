echo "Running validate.py..."
python3 validate.py
echo "Done"
echo " "
echo "Diff in diff.txt" 
diff -y baseline.cflog rebuilt.cflog > diff.txt
