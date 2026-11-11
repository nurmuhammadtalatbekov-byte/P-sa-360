export type Role =
  | 'super_admin' | 'school_admin' | 'director' | 'deputy_director'
  | 'teacher' | 'student' | 'parent' | 'psychologist' | 'mahalla' | 'analyst'

export const roles: { value: Role; label: string }[] = [
  { value: 'super_admin', label: 'Super Admin' },
  { value: 'school_admin', label: 'Maktab administratori' },
  { value: 'director', label: 'Direktor' },
  { value: 'deputy_director', label: 'Direktor o‘rinbosari' },
  { value: 'teacher', label: 'O‘qituvchi' },
  { value: 'student', label: 'O‘quvchi' },
  { value: 'parent', label: 'Ota-ona' },
  { value: 'psychologist', label: 'Psixolog' },
  { value: 'mahalla', label: 'Mahalla vakili' },
  { value: 'analyst', label: 'Tahlilchi' }
]
