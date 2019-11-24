import java.util.HashSet;
import java.util.List;
import java.util.Collection;
import java.util.Arrays;
import java.lang.System;

public class InstrumentedHashSet<E> extends HashSet<E> {
  // The number of attempted element insertions
  public int addCount = 0;
  public InstrumentedHashSet() {
  }
  public InstrumentedHashSet(int initCap, float loadFactor) {
    super(initCap, loadFactor);
  }
  @Override public boolean add(E e) {
    addCount++;
    return super.add(e);
  }
  @Override public boolean addAll(Collection<? extends E> c) {
    addCount += c.size();
    return super.addAll(c);
  }
  public int getAddCount() {
    return addCount;
  }

  public static void main(String[] args) {
    InstrumentedHashSet<String> s = new InstrumentedHashSet<>();
    s.addAll(Arrays.asList("Snap", "Crackle", "Pop"));   //JDK 8
    //s.addAll(List.of("Snap", "Crackle", "Pop"));    //JDK 9
    
    //It prints 6 instead of 3 because add(e) is overridden.
    System.out.println("Total count = " + s.addCount);
  }
}
